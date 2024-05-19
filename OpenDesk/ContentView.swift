import SwiftUI
import AppKit

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var outputHeight: CGFloat = .zero
    @State private var isLoading: Bool = false
    @State private var selectedModel: String = "llama"

    var body: some View {
        VStack {
            Image("llama-medium")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()
            ModelSelectionPopUpButton(selectedModel: $selectedModel)
                            .frame(width: 200, height: 30) // Adjust size as needed
                            .padding()
            
            ScrollView {
                Text(outputText)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    self.outputHeight = .zero
                                }
                                .onChange(of: outputText) { _ in
                                    DispatchQueue.main.async {
                                        self.outputHeight = 25 + (geometry.size.height * 1.5)
                                    }
                                }
                        }
                    )
                    .padding()
            }
            .frame(height: outputHeight)
            .background(Color(nsColor: NSColor.gray)).opacity(0.8).clipShape(RoundedRectangle(cornerRadius: 12))
            if isLoading {
                ProgressView()
                    .padding()
            }
            ZStack {
                TextField("Enter message...", text: $inputText, onCommit: submit)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 21)) // Increase the text size
                    .padding(10) // Padding for text inside the editor
                    .frame(minHeight: 40, maxHeight: 80) // Adjusted heights for TextField
                    .background(Color.clear) // Transparent background
                    .cornerRadius(12) // Corner radius for rounded edges
           
            }
        }
        .padding()
        
    }
    
    func submit() {
        isLoading = true
        let savedInputText = inputText;
        DispatchQueue.main.async {
               inputText = ""
           }
        if let resultImage = captureScreen() {
            saveImageToDisk(image: resultImage)
            let base64Image = getImageBase64(image: resultImage)
            getAnswerFromImageAndPrompt(prompt: savedInputText, image: base64Image, model: selectedModel) { response in
                isLoading = false
                inputText = "";
                if let response = response {
                    print("Received response: \(response)")
                    outputText = response
                } else {
                    print("Failed to get a response.")
                }
            }
        }
    }
    
    func saveImageToDisk(image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return
        }

        let fileManager = FileManager.default
        let desktopURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = desktopURL.appendingPathComponent("capturedScreen.png")

        do {
            try pngData.write(to: fileURL)
            print("Image saved to \(fileURL)")
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func captureScreen() -> NSImage? {
        let mainDisplayID = CGMainDisplayID()
        let imageRef = CGWindowListCreateImage(CGRectNull, .optionOnScreenOnly, kCGNullWindowID, [.nominalResolution])

        guard let image = imageRef else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: image)
        let nsImage = NSImage()
        nsImage.addRepresentation(bitmapRep)
        
        return nsImage
    }
    
    func getImageBase64(image: NSImage) -> String {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return ""
        }
        return pngData.base64EncodedString()
    }
    
}

#Preview {
    ContentView()
}
