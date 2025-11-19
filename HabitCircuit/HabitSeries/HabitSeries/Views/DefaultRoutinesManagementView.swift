import SwiftUI
import CoreData

struct DefaultRoutinesManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RoutineViewModel
    @StateObject private var defaultRoutines = DefaultRoutines()
    @State private var newRoutineName = ""
    @State private var showingAddAlert = false
    @State private var selectedTimeType: RoutineTimeType = .morning
    @State private var showSuccessToast = false
    @State private var toastMessage = ""

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

                // Categorized Built-in Examples
                ForEach(RoutineCategory.allCases, id: \.self) { category in
                    if let routines = DefaultRoutines.categorizedExamples[category], !routines.isEmpty {
                        Section {
                            ForEach(routines, id: \.name) { example in
                                Button(action: {
                                    addExampleRoutine(example)
                                }) {
                                    HStack(spacing: 12) {
                                        // Category icon with background
                                        ZStack {
                                            Circle()
                                                .fill(category.color.opacity(0.15))
                                                .frame(width: 32, height: 32)

                                            Image(systemName: category.icon)
                                                .font(.system(size: 14))
                                                .foregroundColor(category.color)
                                        }

                                        Text(example.name)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.blue.opacity(0.6))
                                    }
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.displayName)
                                    .foregroundColor(category.color)
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                    }
                }
            }
            .navigationTitle(L("default.routines.management"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Time Type Selector
                    Menu {
                        ForEach(RoutineTimeType.allCases, id: \.self) { timeType in
                            Button(action: {
                                selectedTimeType = timeType
                            }) {
                                HStack {
                                    Image(systemName: timeType.icon)
                                    Text(timeType.displayName)
                                    if selectedTimeType == timeType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: selectedTimeType.icon)
                            Text(selectedTimeType.displayName)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showSuccessToast {
                    VStack {
                        Spacer()
                        HStack {
                            Text(L("toast.routine.added"))
                            Text("•")
                            Text(toastMessage)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                        .shadow(radius: 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 80)
                    }
                    .animation(.spring(), value: showSuccessToast)
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

    private func addExampleRoutine(_ example: ExampleRoutineItem) {
        viewModel.addRoutine(
            name: example.name,
            timeType: selectedTimeType,
            category: example.category
        )

        // Show success toast
        toastMessage = "\(example.category.icon) \(example.name)"
        showSuccessToast = true

        // Dismiss after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSuccessToast = false
        }
    }
}

#Preview {
    DefaultRoutinesManagementView(
        viewModel: RoutineViewModel(
            context: PersistenceController.preview.container.viewContext
        )
    )
}
