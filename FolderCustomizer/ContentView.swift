import SwiftUI
import AppKit

struct ContentView: View {
    @State private var folderURL: URL?
    @State private var iconImage: NSImage?
    @State private var statusMessage: String = "Ready to customize"
    @State private var isHoveringFolder = false
    @State private var isHoveringImage = false

    var body: some View {
        ZStack {
            // Background: Native Blur + Subtle Warm Glow
            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            // This creates that "Full Width" colorful look from your screenshot
            RadialGradient(colors: [Color.orange.opacity(0.2), Color.clear], center: .center, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Iconic")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .tracking(-1)
                    Text("Professional folder customization")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                Spacer()

                // Selection Area
                HStack(spacing: 40) {
                    SelectionCard(
                        title: folderURL?.lastPathComponent ?? "Select Folder",
                        subtitle: "Target",
                        icon: "folder.fill",
                        image: nil,
                        isSelected: folderURL != nil,
                        isHovering: isHoveringFolder,
                        action: selectFolder
                    )
                    .onHover { isHoveringFolder = $0 }

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.3))

                    SelectionCard(
                        title: iconImage != nil ? "Image Loaded" : "Select Icon",
                        subtitle: "Source",
                        icon: "photo.fill",
                        image: iconImage,
                        isSelected: iconImage != nil,
                        isHovering: isHoveringImage,
                        action: selectImage
                    )
                    .onHover { isHoveringImage = $0 }
                }

                Spacer()

                // Action Area
                VStack(spacing: 20) {
                    Button(action: applyNewIcon) {
                        Text("Apply Transformation")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 320, height: 48)
                            .background(canApply ? Color.blue : Color.white.opacity(0.1))
                            .cornerRadius(14)
                            .shadow(color: canApply ? Color.blue.opacity(0.4) : .clear, radius: 15, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canApply)

                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(statusMessage.contains("Success") ? .orange : .secondary)
                        .transition(.opacity)
                }
                .padding(.bottom, 50)
            }
        }
        .frame(minWidth: 600, minHeight: 450)
    }

    var canApply: Bool {
        folderURL != nil && iconImage != nil
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            self.folderURL = panel.url
            statusMessage = "Target folder set."
        }
    }

    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg]
        if panel.runModal() == .OK, let url = panel.url {
            self.iconImage = NSImage(contentsOf: url)
            statusMessage = "Icon image loaded."
        }
    }

    func applyNewIcon() {
        guard let folder = folderURL, let icon = iconImage else { return }
        let success = NSWorkspace.shared.setIcon(icon, forFile: folder.path, options: [])
        
        if success {
            withAnimation(.spring()) {
                statusMessage = "Success! Icon updated."
                // Resetting both selections
                self.folderURL = nil
                self.iconImage = nil
            }
            NSSound(named: "Glass")?.play()
        } else {
            statusMessage = "Failed to apply icon."
        }
    }
}

// Support Views
struct SelectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let image: NSImage?
    let isSelected: Bool
    let isHovering: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(isHovering ? 0.1 : 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5)
                        )

                    if let image = image {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill() // Better for filling the card width
                            .frame(width: 110, height: 110)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 50))
                            .foregroundColor(isSelected ? .blue : .secondary.opacity(0.7))
                    }
                }
                .frame(width: 180, height: 180)

                VStack(spacing: 4) {
                    Text(subtitle.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.secondary)
                        .kerning(1)
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .lineLimit(1)
                        .frame(width: 160)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
