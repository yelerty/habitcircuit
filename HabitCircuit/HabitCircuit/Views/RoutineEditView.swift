import SwiftUI

struct RoutineEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RoutineViewModel
    @State private var newRoutineName: String = ""
    @State private var editingRoutine: RoutineItem?
    @State private var editingText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Add Routine Section
                VStack(spacing: 12) {
                    HStack {
                        TextField("새 루틴 추가", text: $newRoutineName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                addRoutine()
                            }

                        Button(action: addRoutine) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    Text("추가한 순서대로 루틴이 진행됩니다")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                                HStack {
                                    TextField("루틴 이름", text: $editingText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("저장") {
                                        saveEdit()
                                    }
                                    .foregroundColor(.blue)

                                    Button("취소") {
                                        cancelEdit()
                                    }
                                    .foregroundColor(.red)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.gray)

                                    Text("\(routine.order + 1).")
                                        .foregroundColor(.gray)
                                        .frame(width: 30)

                                    Text(routine.name)
                                        .font(.body)

                                    Spacer()

                                    Button(action: {
                                        startEditing(routine: routine)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .onDelete(perform: deleteRoutine)
                        .onMove(perform: moveRoutine)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("\(viewModel.selectedDay.rawValue) 루틴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("완료") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .disabled(viewModel.routines.isEmpty)
                }
            }
        }
    }

    private func addRoutine() {
        let trimmedName = newRoutineName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        viewModel.addRoutine(name: trimmedName)
        newRoutineName = ""
    }

    private func deleteRoutine(at offsets: IndexSet) {
        viewModel.deleteRoutine(at: offsets)
    }

    private func moveRoutine(from source: IndexSet, to destination: Int) {
        viewModel.moveRoutine(from: source, to: destination)
    }

    private func startEditing(routine: RoutineItem) {
        editingRoutine = routine
        editingText = routine.name
    }

    private func saveEdit() {
        guard let routine = editingRoutine else { return }
        let trimmedName = editingText.trimmingCharacters(in: .whitespaces)

        if !trimmedName.isEmpty {
            viewModel.updateRoutine(id: routine.id, newName: trimmedName)
        }

        cancelEdit()
    }

    private func cancelEdit() {
        editingRoutine = nil
        editingText = ""
    }
}

struct RoutineEditView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineEditView(
            viewModel: RoutineViewModel(context: PersistenceController.shared.container.viewContext)
        )
    }
}
