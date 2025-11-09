import SwiftUI
import CoreData

struct RoutineEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RoutineViewModel
    @State private var newRoutineName: String = ""
    @State private var editingRoutine: RoutineItem?
    @State private var editingText: String = ""
    @State private var editingCategory: RoutineCategory = .other
    @State private var showDefaultRoutines = false
    @State private var showDeleteConfirmation = false
    @State private var routineToDelete: IndexSet?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .success
    @State private var selectedCategory: RoutineCategory = .other
    @State private var showCategoryPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Time Type Selector for Edit
                HStack(spacing: 12) {
                    ForEach(RoutineTimeType.allCases, id: \.self) { timeType in
                        let routineCount = viewModel.getRoutineCount(for: timeType)

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            viewModel.changeTimeType(timeType)
                        }) {
                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: timeType.icon)
                                        .font(.caption)
                                    Text(timeType.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                }

                                // Routine count badge
                                if routineCount > 0 {
                                    Text("\(routineCount)개")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(viewModel.selectedTimeType == timeType ? .white.opacity(0.8) : timeTypeColor(timeType))
                                }
                            }
                            .foregroundColor(viewModel.selectedTimeType == timeType ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.selectedTimeType == timeType ? timeTypeColor(timeType) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.selectedTimeType == timeType ? timeTypeColor(timeType).opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                        }
                        .bouncyButton()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))

                Divider()

                // Add Routine Section
                VStack(spacing: 12) {
                    // Category Selector
                    Button(action: {
                        showCategoryPicker.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: selectedCategory.icon)
                                .foregroundColor(selectedCategory.color)
                            Text(selectedCategory.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory.color.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                        )
                    }

                    HStack {
                        TextField("새 루틴 추가", text: $newRoutineName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                addRoutine()
                            }

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            addRoutine()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(timeTypeColor(viewModel.selectedTimeType))
                        }
                        .disabled(newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .pressEffect()
                    }

                    if showCategoryPicker {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(RoutineCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                        showCategoryPicker = false
                                    }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: category.icon)
                                                .font(.title3)
                                                .foregroundColor(selectedCategory == category ? .white : category.color)
                                            Text(category.rawValue)
                                                .font(.caption2)
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                        }
                                        .frame(width: 70, height: 70)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedCategory == category ? category.color : category.color.opacity(0.1))
                                        )
                                    }
                                    .bouncyButton()
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .transition(.opacity)
                    }

                    HStack {
                        Text("추가한 순서대로 루틴이 진행됩니다")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Spacer()

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showDefaultRoutines = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                Text("예시 보기")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                        .bouncyButton()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))

                Divider()

                // Routine List
                if viewModel.routines.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("루틴을 추가해주세요")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("위 입력창에서 루틴을 추가하고\n순서를 드래그로 변경할 수 있습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.routines) { routine in
                            if editingRoutine?.id == routine.id {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Category icon picker
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(RoutineCategory.allCases, id: \.self) { category in
                                                Button(action: {
                                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                                    generator.impactOccurred()
                                                    editingCategory = category
                                                }) {
                                                    VStack(spacing: 4) {
                                                        Image(systemName: category.icon)
                                                            .font(.title3)
                                                        Text(category.rawValue)
                                                            .font(.caption2)
                                                    }
                                                    .foregroundColor(editingCategory == category ? .white : category.color)
                                                    .frame(width: 60, height: 60)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(editingCategory == category ? category.color : category.color.opacity(0.1))
                                                    )
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }

                                    // Name and action buttons
                                    HStack {
                                        TextField("루틴 이름", text: $editingText)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())

                                        Button("저장") {
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            saveEdit()
                                        }
                                        .foregroundColor(.blue)
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button("취소") {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            cancelEdit()
                                        }
                                        .foregroundColor(.red)
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                HStack {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.gray)

                                    Text("\(routine.order + 1).")
                                        .foregroundColor(.gray)
                                        .frame(width: 30)

                                    // Category icon
                                    Image(systemName: routine.category.icon)
                                        .foregroundColor(routine.category.color)
                                        .font(.caption)
                                        .frame(width: 24)

                                    Text(routine.name)
                                        .font(.body)

                                    Spacer()

                                    Button(action: {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        startEditing(routine: routine)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .onDelete(perform: deleteRoutine)
                        .onMove(perform: moveRoutine)
                    }
                    .listStyle(PlainListStyle())
                    .id(viewModel.routines.map { $0.id })
                }
            }
            .navigationTitle("\(viewModel.selectedDay.rawValue) 루틴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("완료") {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .disabled(viewModel.routines.isEmpty)
                }
            }
            .sheet(isPresented: $showDefaultRoutines) {
                DefaultRoutinesSheet(onSelect: { routineName in
                    viewModel.addRoutine(name: routineName)
                    showSuccessToast("루틴이 추가되었습니다")
                })
            }
            .alert("루틴 삭제", isPresented: $showDeleteConfirmation) {
                Button("취소", role: .cancel) {
                    routineToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let offsets = routineToDelete {
                        performDelete(at: offsets)
                    }
                }
            } message: {
                Text("이 루틴을 삭제하시겠습니까?\n삭제된 루틴은 복구할 수 없습니다.")
            }
            .toast(isShowing: $showToast, message: toastMessage, type: toastType)
        }
    }

    private func addRoutine() {
        let trimmedName = newRoutineName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        viewModel.addRoutine(name: trimmedName, category: selectedCategory)
        newRoutineName = ""

        // Show success toast
        showSuccessToast("'\(trimmedName)' 루틴이 추가되었습니다")
    }

    private func deleteRoutine(at offsets: IndexSet) {
        routineToDelete = offsets
        showDeleteConfirmation = true
    }

    private func performDelete(at offsets: IndexSet) {
        print("🎯 RoutineEditView - deleteRoutine called with offsets: \(offsets)")
        print("🎯 Before delete - viewModel.routines.count: \(viewModel.routines.count)")

        let routineNames = offsets.map { viewModel.routines[$0].name }.joined(separator: ", ")

        viewModel.deleteRoutine(at: offsets)
        print("🎯 After delete - viewModel.routines.count: \(viewModel.routines.count)")

        // Show success toast
        showSuccessToast("'\(routineNames)' 루틴이 삭제되었습니다")
        routineToDelete = nil
    }

    private func moveRoutine(from source: IndexSet, to destination: Int) {
        viewModel.moveRoutine(from: source, to: destination)
    }

    private func startEditing(routine: RoutineItem) {
        editingRoutine = routine
        editingText = routine.name
        editingCategory = routine.category
    }

    private func saveEdit() {
        guard let routine = editingRoutine else { return }
        let trimmedName = editingText.trimmingCharacters(in: .whitespaces)

        print("🎯 RoutineEditView - saveEdit called")
        print("🎯 Before update - viewModel.routines.count: \(viewModel.routines.count)")

        if !trimmedName.isEmpty {
            viewModel.updateRoutine(id: routine.id, newName: trimmedName, newCategory: editingCategory)
            showSuccessToast("루틴이 수정되었습니다")
        }

        print("🎯 After update - viewModel.routines.count: \(viewModel.routines.count)")
        cancelEdit()
    }

    private func cancelEdit() {
        editingRoutine = nil
        editingText = ""
        editingCategory = .other
    }

    private func showSuccessToast(_ message: String) {
        toastMessage = message
        toastType = .success
        showToast = true
    }

    private func showErrorToast(_ message: String) {
        toastMessage = message
        toastType = .error
        showToast = true
    }

    private func timeTypeColor(_ timeType: RoutineTimeType) -> Color {
        switch timeType {
        case .morning: return .orange
        case .afternoon: return .yellow
        case .evening: return .indigo
        }
    }
}

// MARK: - Default Routines Sheet
struct DefaultRoutinesSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var defaultRoutines = DefaultRoutines()
    @State private var newRoutineName = ""
    @State private var showingAddAlert = false
    @State private var selectedRoutine: String?
    @State private var showCheckmark = false

    let onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Add Custom Routine Section
                VStack(spacing: 8) {
                    HStack {
                        TextField("나만의 루틴 추가", text: $newRoutineName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                addCustomRoutine()
                            }

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            addCustomRoutine()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        .disabled(newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .pressEffect()
                    }

                    Text("자주 사용하는 루틴을 추가하여 관리하세요")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.green.opacity(0.05))

                Divider()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("원하는 루틴을 탭하여 추가하세요")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top)

                        // Custom Routines Section
                        if !defaultRoutines.customRoutines.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text("나만의 루틴")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal)

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(Array(defaultRoutines.customRoutines.enumerated()), id: \.element) { index, routine in
                                        HStack {
                                            Button(action: {
                                                // Strong haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                                generator.impactOccurred()

                                                // Visual feedback - show checkmark animation
                                                selectedRoutine = routine
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    showCheckmark = true
                                                }

                                                // Hide checkmark and execute selection
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation {
                                                        showCheckmark = false
                                                    }
                                                    selectedRoutine = nil
                                                }

                                                onSelect(routine)
                                            }) {
                                                ZStack {
                                                    HStack {
                                                        Image(systemName: "plus.circle.fill")
                                                            .foregroundColor(.green)
                                                            .font(.caption)

                                                        Text(routine)
                                                            .font(.body)
                                                            .foregroundColor(.primary)

                                                        Spacer()
                                                    }

                                                    // Checkmark overlay
                                                    if selectedRoutine == routine && showCheckmark {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.title)
                                                            .foregroundColor(.green)
                                                            .transition(.scale.combined(with: .opacity))
                                                    }
                                                }
                                            }
                                            .bouncyButton()

                                            Button(action: {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                                defaultRoutines.deleteCustomRoutine(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                            .pressEffect()
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.green.opacity(0.1))
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Divider()
                                .padding(.vertical, 8)
                        }

                        // Built-in Routines Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("기본 예시")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(DefaultRoutines.builtInExamples, id: \.self) { routine in
                                    Button(action: {
                                        // Strong haptic feedback
                                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                                        generator.impactOccurred()

                                        // Visual feedback - show checkmark animation
                                        selectedRoutine = routine
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            showCheckmark = true
                                        }

                                        // Hide checkmark and execute selection
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation {
                                                showCheckmark = false
                                            }
                                            selectedRoutine = nil
                                        }

                                        onSelect(routine)
                                    }) {
                                        ZStack {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)

                                                Text(routine)
                                                    .font(.body)
                                                    .foregroundColor(.primary)

                                                Spacer()
                                            }

                                            // Checkmark overlay
                                            if selectedRoutine == routine && showCheckmark {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title)
                                                    .foregroundColor(.blue)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                    }
                                    .bouncyButton()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("루틴 예시")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
            }
        }
    }

    private func addCustomRoutine() {
        let trimmed = newRoutineName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        defaultRoutines.addCustomRoutine(trimmed)
        newRoutineName = ""
    }
}

struct RoutineEditView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineEditView(
            viewModel: RoutineViewModel(context: PersistenceController.shared.container.viewContext)
        )
    }
}
