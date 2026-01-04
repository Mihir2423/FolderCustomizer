import SwiftUI
import AppKit

struct ContentView: View {
    @State private var folderURL: URL?
    @State private var iconImage: NSImage?
    @State private var statusMessage: String = "IDLE"
    @State private var isHoveringApply = false

    var body: some View {
        VStack(spacing: 0) {
            // Main Workbench
            HStack(spacing: 0) {
                // Left Slot: Target
                FileSlot(
                    title: "TARGET FOLDER",
                    subtitle: folderURL?.lastPathComponent ?? "Not selected",
                    systemIcon: "folder",
                    isFilled: folderURL != nil,
                    action: selectFolder
                )
                
                // Connection Bridge
                ZStack {
                    Rectangle().fill(Color(white: 0.15)).frame(width: 1)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(canApply ? .white : Color(white: 0.2))
                        .background(Color.black)
                        .padding(.vertical, 10)
                }
                .frame(width: 40)

                // Right Slot: Source
                FileSlot(
                    title: "SOURCE IMAGE",
                    subtitle: iconImage != nil ? "Image loaded" : "Not selected",
                    systemIcon: "plus",
                    image: iconImage,
                    isFilled: iconImage != nil,
                    action: selectImage
                )
            }
            .padding(24)
            
            // Bottom Action Bar
            VStack(spacing: 0) {
                Divider().background(Color(white: 0.15))
                
                HStack {
                    // Status Badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(canApply ? Color.green : Color(white: 0.2))
                            .frame(width: 6, height: 6)
                        Text(statusMessage.uppercased())
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(white: 0.5))
                    }
                    
                    Spacer()
                    
                    Button(action: applyNewIcon) {
                        Text("Deploy Icon")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(canApply ? .black : Color(white: 0.4))
                            .padding(.horizontal, 16)
                            .frame(height: 32)
                            .background(canApply ? Color.white : Color(white: 0.1))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canApply)
                }
                .padding(.horizontal, 24)
                .frame(height: 60)
                .background(Color(white: 0.03))
            }
        }
        .frame(width: 520, height: 300)
        .background(Color.black)
    }

    var canApply: Bool { folderURL != nil && iconImage != nil }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            self.folderURL = panel.url
            statusMessage = "Ready to deploy"
        }
    }

    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg]
        if panel.runModal() == .OK, let url = panel.url {
            self.iconImage = NSImage(contentsOf: url)
            statusMessage = "Ready to deploy"
        }
    }

    func applyNewIcon() {
        guard let folder = folderURL, let icon = iconImage else { return }
        let success = NSWorkspace.shared.setIcon(icon, forFile: folder.path, options: [])
        statusMessage = success ? "Success" : "Error"
        if success {
            self.folderURL = nil
            self.iconImage = nil
        }
    }
}

struct FileSlot: View {
    let title: String
    let subtitle: String
    let systemIcon: String
    var image: NSImage?
    let isFilled: Bool
    let action: () -> Void
    
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(white: 0.4))
                    .kerning(0.5)

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isHovered ? Color(white: 0.3) : Color(white: 0.15), lineWidth: 1)
                        .background(Color(white: 0.05))
                    
                    if let image = image {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    } else {
                        Image(systemName: systemIcon)
                            .font(.system(size: 18))
                            .foregroundColor(isFilled ? .white : Color(white: 0.2))
                    }
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(isFilled ? .white : Color(white: 0.3))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
