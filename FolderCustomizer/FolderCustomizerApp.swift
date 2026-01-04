import SwiftUI

@main
struct FolderCustomizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // This sets the text in the top bar
                .navigationTitle("Folder Customizer")
        }
        // This ensures the window opens at a nice size
        .windowResizability(.contentSize)
    }
}
