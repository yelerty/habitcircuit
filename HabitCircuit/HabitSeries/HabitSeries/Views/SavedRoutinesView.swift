import SwiftUI
import CoreData

struct SavedRoutinesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var savedRoutineManager = SavedRoutineManager.shared
    @ObservedObject var viewModel: RoutineViewModel

    @State private var showSaveDialog = false
    @State private var saveTitle = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLoadConfirm = false
    @State private var selectedSlotToLoad: Int?
    @State private var showDeleteAllConfirm = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("루틴 저장 슬롯")
                            .font(.headline)
                        Text("\(savedRoutineManager.savedSlots.count)/5 사용 중")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    Button(action: {
                        if savedRoutineManager.isFull {
                            alertMessage = "저장 슬롯이 가득 찼습니다. 기존 슬롯을 삭제하고 다시 시도해주세요."
                            showAlert = true
                        } else {
                            showSaveDialog = true
                        }
                    }) {
                        Label("현재 루틴 저장", systemImage: "square.and.arrow.down")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(savedRoutineManager.isFull ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(savedRoutineManager.isFull)
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // Delete All Button
                Button(action: {
                    showDeleteAllConfirm = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("현재 루틴 모두 삭제")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Divider()
                    .padding(.top, 8)

                // Saved Slots List
                if savedRoutineManager.savedSlots.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("저장된 루틴이 없습니다")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("현재 루틴을 저장하여\n나중에 불러올 수 있습니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(savedRoutineManager.savedSlots, id: \.id) { slot in
                            SavedSlotRow(
                                slot: slot,
                                onLoad: {
                                    selectedSlotToLoad = slot.slotNumber
                                    showLoadConfirm = true
                                },
                                onDelete: {
                                    savedRoutineManager.deleteSlot(slotNumber: slot.slotNumber)
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("저장된 루틴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("루틴 저장", isPresented: $showSaveDialog) {
                TextField("제목 입력", text: $saveTitle)
                Button("저장") {
                    saveCurrentRoutines()
                }
                Button("취소", role: .cancel) {
                    saveTitle = ""
                }
            } message: {
                Text("현재 모든 요일의 모든 루틴을 저장합니다")
            }
            .alert("루틴 불러오기", isPresented: $showLoadConfirm) {
                Button("불러오기", role: .destructive) {
                    if let slotNumber = selectedSlotToLoad {
                        loadRoutines(from: slotNumber)
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("⚠️ 현재 모든 루틴이 삭제되고\n저장된 루틴으로 교체됩니다.\n\n진행하시겠습니까?")
            }
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .alert("모든 루틴 삭제", isPresented: $showDeleteAllConfirm) {
                Button("삭제", role: .destructive) {
                    deleteAllRoutines()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("⚠️ 현재 모든 요일의 모든 루틴이 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.\n진행하시겠습니까?")
            }
        }
    }

    private func saveCurrentRoutines() {
        let title = saveTitle.isEmpty ? "내 루틴" : saveTitle

        // Get all routines from viewModel
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Routine.dayOfWeek, ascending: true),
            NSSortDescriptor(keyPath: \Routine.timeType, ascending: true),
            NSSortDescriptor(keyPath: \Routine.order, ascending: true)
        ]

        do {
            let context = PersistenceController.shared.container.viewContext
            let results = try context.fetch(request)
            let routineItems = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: false
                )
            }

            if routineItems.isEmpty {
                alertMessage = "저장할 루틴이 없습니다"
                showAlert = true
                return
            }

            // Count days
            let uniqueDays = Set(routineItems.map { $0.dayOfWeek })

            let success = savedRoutineManager.saveRoutinesToSlot(title: title, routines: routineItems)
            if success {
                alertMessage = "루틴이 성공적으로 저장되었습니다\n(\(uniqueDays.count)개 요일, 총 \(routineItems.count)개 루틴)"
                saveTitle = ""
            } else {
                alertMessage = "루틴 저장에 실패했습니다"
            }
            showAlert = true
        } catch {
            alertMessage = "루틴 저장 중 오류가 발생했습니다"
            showAlert = true
        }
    }

    private func loadRoutines(from slotNumber: Int) {
        guard let routines = savedRoutineManager.loadRoutinesFromSlot(slotNumber: slotNumber) else {
            alertMessage = "루틴을 불러오는데 실패했습니다"
            showAlert = true
            return
        }

        // Delete all existing routines
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Routine")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)

        do {
            let context = PersistenceController.shared.container.viewContext
            try context.execute(batchDelete)

            // Import loaded routines
            for routineItem in routines {
                let routine = Routine(context: context)
                routine.id = UUID()
                routine.name = routineItem.name
                routine.dayOfWeek = routineItem.dayOfWeek
                routine.timeType = routineItem.timeType.rawValue
                routine.order = Int16(routineItem.order)
                routine.isCompleted = false
                routine.createdAt = Date()
            }

            try context.save()
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()

            alertMessage = "루틴을 성공적으로 불러왔습니다"
            showAlert = true
        } catch {
            alertMessage = "루틴을 불러오는 중 오류가 발생했습니다"
            showAlert = true
        }
    }

    private func deleteAllRoutines() {
        let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()

        do {
            let context = PersistenceController.shared.container.viewContext

            // Fetch all existing routines
            let existingRoutines = try context.fetch(fetchRequest)

            // Delete each routine individually
            for routine in existingRoutines {
                context.delete(routine)
            }

            // Save the deletion
            try context.save()

            print("✅ Successfully deleted \(existingRoutines.count) routines")

            // Reload data in viewModel
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()

            alertMessage = "모든 루틴이 삭제되었습니다 (\(existingRoutines.count)개)"
            showAlert = true
        } catch {
            print("Failed to delete all routines: \(error)")
            alertMessage = "루틴 삭제 중 오류가 발생했습니다: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct SavedSlotRow: View {
    let slot: SavedRoutineSlotInfo
    let onLoad: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // Slot Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Text("\(slot.slotNumber + 1)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            // Slot Info
            VStack(alignment: .leading, spacing: 4) {
                Text(slot.title)
                    .font(.headline)
                Text("\(slot.dayCount)개 요일 · \(slot.routineCount)개 루틴")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(formatDate(slot.savedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onLoad) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)

                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .alert("슬롯 삭제", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("'\(slot.title)' 슬롯을 삭제하시겠습니까?")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
}

struct SavedRoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedRoutinesView(viewModel: RoutineViewModel(context: PersistenceController.shared.container.viewContext))
    }
}
