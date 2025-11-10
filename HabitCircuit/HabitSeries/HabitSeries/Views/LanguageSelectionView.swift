import SwiftUI

struct LanguageSelectionView: View {
    @Binding var isPresented: Bool
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedLanguage: AppLanguage

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguage)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                        localizationManager.currentLanguage = language

                        // Delay to allow UI to update, then restart app
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Restart the app by exiting and letting user reopen
                            exit(0)
                        }
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.largeTitle)

                            Text(language.displayName)
                                .font(.body)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L("settings.language.selection"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
