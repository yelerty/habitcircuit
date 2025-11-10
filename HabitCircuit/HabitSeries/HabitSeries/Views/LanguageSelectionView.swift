import SwiftUI

struct LanguageSelectionView: View {
    @Binding var isPresented: Bool
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedLanguage: AppLanguage
    @State private var showRestartAlert = false

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

                        // Save language change
                        localizationManager.currentLanguage = language

                        // Show restart alert
                        showRestartAlert = true
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
            .alert(selectedLanguage == .korean ? "언어가 변경되었습니다" : "Language Changed", isPresented: $showRestartAlert) {
                Button(selectedLanguage == .korean ? "앱 재시작" : "Restart App", role: .destructive) {
                    // Exit app - user will need to manually restart
                    exit(0)
                }
                Button(selectedLanguage == .korean ? "나중에" : "Later", role: .cancel) {
                    isPresented = false
                }
            } message: {
                Text(selectedLanguage == .korean ?
                    "언어 변경을 완전히 적용하려면 앱을 재시작해야 합니다." :
                    "Please restart the app to fully apply the language change.")
            }
        }
    }
}
