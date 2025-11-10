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
                            Text(L("default.routines.add.new"))
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Label(L("default.routines.my.examples"), systemImage: "star.fill")
                } footer: {
                    Text(L("default.routines.info"))
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
                    Label(L("default.routines.provided"), systemImage: "list.bullet")
                } footer: {
                    Text(L("default.routines.cannot.delete"))
                }
            }
            .navigationTitle(L("default.routines.management"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                }
            }
            .alert(L("default.routines.add.title"), isPresented: $showingAddAlert) {
                TextField(L("routine.name"), text: $newRoutineName)
                Button(L("cancel"), role: .cancel) {
                    newRoutineName = ""
                }
                Button(L("routine.add")) {
                    if !newRoutineName.trimmingCharacters(in: .whitespaces).isEmpty {
                        defaultRoutines.addCustomRoutine(newRoutineName)
                        newRoutineName = ""
                    }
                }
            } message: {
                Text(L("default.routines.add.message"))
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
