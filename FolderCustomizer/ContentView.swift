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
            // macOS Native Background Blur
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Iconic")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Professional folder customization")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)

                // Selection Area
                HStack(spacing: 20) {
                    // Folder Slot
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
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.5))

                    // Image Slot
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
                .padding(.horizontal, 30)

                Spacer()

                // Apply Button
                VStack(spacing: 15) {
                    Button(action: applyNewIcon) {
                        Text("Apply Transformation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(canApply ? Color.blue : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                            .shadow(color: canApply ? Color.blue.opacity(0.3) : .clear, radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canApply)

                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .frame(width: 500, height: 420)
    }

    var canApply: Bool {
        folderURL != nil && iconImage != nil
    }

    // MARK: - Logic

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
        
        withAnimation {
            statusMessage = success ? "Success! Icon updated." : "Permission denied."
        }
        
        if success {
            // Optional: Haptic/Sound feedback
            NSSound(named: "Glass")?.play()
        }
    }
}

// MARK: - Subviews

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
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(isHovering ? 0.15 : 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                    if let image = image {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundColor(isSelected ? .blue : .secondary)
                    }
                }
                .frame(width: 140, height: 140)

                VStack(spacing: 4) {
                    Text(subtitle.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        .animation(.spring(), value: isSelected)
    }
}

// Helper for Background Blur
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
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
