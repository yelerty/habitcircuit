import SwiftUI

struct DefaultRoutinesManagementView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var defaultRoutines = DefaultRoutines()
    @State private var newRoutineName = ""
    @State private var showingAddAlert = false

    var body: some View {
        NavigationView {
            List {
                // Custom Routines Section
                Section {
                    ForEach(defaultRoutines.customRoutines, id: \.self) { routine in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(routine)
                        }
                    }
                    .onDelete(perform: deleteCustomRoutine)

                    Button(action: {
                        showingAddAlert = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("새 예시 루틴 추가")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Label("내가 추가한 예시 루틴", systemImage: "star.fill")
                } footer: {
                    Text("루틴 편집 화면에서 이 예시들을 빠르게 추가할 수 있습니다.")
                }

                // Built-in Examples Section
                Section {
                    ForEach(DefaultRoutines.builtInExamples, id: \.self) { routine in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.gray)
                                .font(.caption2)
                            Text(routine)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("기본 제공 예시 루틴", systemImage: "list.bullet")
                } footer: {
                    Text("기본 제공 예시는 삭제할 수 없습니다.")
                }
            }
            .navigationTitle("예시 루틴 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("새 예시 루틴 추가", isPresented: $showingAddAlert) {
                TextField("루틴 이름", text: $newRoutineName)
                Button("취소", role: .cancel) {
                    newRoutineName = ""
                }
                Button("추가") {
                    if !newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty {
                        defaultRoutines.addCustomRoutine(newRoutineName)
                        newRoutineName = ""
                    }
                }
            } message: {
                Text("추가할 예시 루틴의 이름을 입력하세요.")
            }
        }
    }

    private func deleteCustomRoutine(at offsets: IndexSet) {
        for index in offsets {
            defaultRoutines.deleteCustomRoutine(at: index)
        }
    }
}

#Preview {
    DefaultRoutinesManagementView()
}
