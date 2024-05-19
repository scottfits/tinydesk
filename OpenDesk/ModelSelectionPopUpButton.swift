import SwiftUI
import AppKit

struct ModelSelectionPopUpButton: NSViewRepresentable {
    @Binding var selectedModel: String

    class Coordinator: NSObject {
        var parent: ModelSelectionPopUpButton

        init(parent: ModelSelectionPopUpButton) {
            self.parent = parent
        }

        @objc func modelSelectionChanged(_ sender: NSPopUpButton) {
            if let selectedItem = sender.selectedItem?.title {
                parent.selectedModel = selectedItem
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSPopUpButton {
        let popUpButton = NSPopUpButton()
        popUpButton.addItems(withTitles: ["llama", "gpt", "gemini"])
        popUpButton.target = context.coordinator
        popUpButton.action = #selector(Coordinator.modelSelectionChanged(_:))
        return popUpButton
    }

    func updateNSView(_ nsView: NSPopUpButton, context: Context) {
        let index = nsView.indexOfItem(withTitle: selectedModel)
        nsView.selectItem(at: index)
        
    }
}
