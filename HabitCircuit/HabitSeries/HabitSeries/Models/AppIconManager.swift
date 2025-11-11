import SwiftUI
import PhotosUI
import Combine

class AppIconManager: ObservableObject {
    static let shared = AppIconManager()

    @Published var customIconData: Data?

    private let iconKey = "CustomAppIcon"

    private init() {
        loadIcon()
    }

    func loadIcon() {
        if let data = UserDefaults.standard.data(forKey: iconKey) {
            customIconData = data
        }
    }

    func saveIcon(_ imageData: Data) {
        UserDefaults.standard.set(imageData, forKey: iconKey)
        customIconData = imageData
    }

    func removeIcon() {
        UserDefaults.standard.removeObject(forKey: iconKey)
        customIconData = nil
    }

    func getIcon() -> UIImage? {
        guard let data = customIconData else { return nil }
        return UIImage(data: data)
    }
}
