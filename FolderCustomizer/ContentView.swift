import SwiftUI
import AppKit

struct ContentView: View {
    @State private var folderURL: URL?
    @State private var iconImage: NSImage?
    @State private var folderContents: [String] = []
    @State private var statusMessage: String = "Select a folder to begin"

    var body: some View {
        VStack(spacing: 20) {
            Text("Folder Icon Customizer")
                .font(.title)
                .padding(.top)

            // 1. Folder Selection and Preview
            VStack {
                Button("Select Folder from Desktop") {
                    selectFolder()
                }
                
                if let folder = folderURL {
                    Text("Selected: \(folder.lastPathComponent)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    // Folder Preview List
                    List(folderContents, id: \.self) { fileName in
                        Label(fileName, systemImage: "doc")
                    }
                    .frame(height: 150)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            Divider()

            // 2. Icon Selection
            VStack {
                Button("Select Custom Icon Image") {
                    selectImage()
                }
                
                if let image = iconImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }

            // 3. Apply Action
            Button(action: applyNewIcon) {
                Text("Apply New Icon")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(folderURL == nil || iconImage == nil)
            .padding()

            Text(statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(width: 400, height: 550)
    }

    // MARK: - Logic Functions

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first

        if panel.runModal() == .OK {
            self.folderURL = panel.url
            updateFolderPreview()
            statusMessage = "Folder selected. Now pick an image."
        }
    }

    func updateFolderPreview() {
        guard let url = folderURL else { return }
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: url.path)
            self.folderContents = items.filter { !$0.hasPrefix(".") } // Hide hidden files
        } catch {
            statusMessage = "Error reading folder contents."
        }
    }

    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            if let img = NSImage(contentsOf: url) {
                self.iconImage = img
                statusMessage = "Image loaded. Ready to apply!"
            }
        }
    }

    func applyNewIcon() {
        guard let folder = folderURL, let icon = iconImage else { return }
        
        // This is the core macOS API that changes the icon
        let success = NSWorkspace.shared.setIcon(icon, forFile: folder.path, options: [])
        
        if success {
            statusMessage = "Success! Icon changed for \(folder.lastPathComponent)."
        } else {
            statusMessage = "Failed to set icon. Check permissions."
        }
    }
}
