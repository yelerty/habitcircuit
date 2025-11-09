//
//  ShareViewController.swift
//  ShareExtension
//
//  Created for HabitCircuit
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the shared item
        handleSharedItem()
    }

    private func handleSharedItem() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            closeExtension(with: "공유할 항목을 찾을 수 없습니다.")
            return
        }

        // Check if it's a JSON file
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.json.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.json.identifier, options: nil) { [weak self] (item, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.closeExtension(with: "파일을 불러오는데 실패했습니다: \(error.localizedDescription)")
                        return
                    }

                    guard let url = item as? URL else {
                        self?.closeExtension(with: "파일 형식이 올바르지 않습니다.")
                        return
                    }

                    self?.importRoutine(from: url)
                }
            }
        } else {
            closeExtension(with: "JSON 파일만 공유할 수 있습니다.")
        }
    }

    private func importRoutine(from url: URL) {
        // Access security scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            closeExtension(with: "파일 접근 권한이 없습니다.")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            // Read file data
            let data = try Data(contentsOf: url)

            // Save to shared container (App Group)
            if let sharedContainerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.habitcircuit.shared") {

                let fileURL = sharedContainerURL.appendingPathComponent("pending_import.json")
                try data.write(to: fileURL)

                // Show success and close
                showSuccessAndClose()
            } else {
                closeExtension(with: "앱 그룹 컨테이너를 찾을 수 없습니다.")
            }
        } catch {
            closeExtension(with: "파일을 처리하는데 실패했습니다: \(error.localizedDescription)")
        }
    }

    private func showSuccessAndClose() {
        let alert = UIAlertController(
            title: "✅ 성공",
            message: "HabitCircuit 앱을 열면 루틴이 자동으로 추가됩니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "앱 열기", style: .default) { [weak self] _ in
            self?.openMainApp()
        })

        alert.addAction(UIAlertAction(title: "닫기", style: .cancel) { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })

        present(alert, animated: true)
    }

    private func openMainApp() {
        // Open main app using URL scheme
        let url = URL(string: "habitcircuit://import")!
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                break
            }
            responder = responder?.next
        }

        // Close extension
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func closeExtension(with message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })

        present(alert, animated: true)
    }
}
