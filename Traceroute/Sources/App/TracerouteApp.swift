import SwiftUI
import UI
import Core

/// Main application entry point
@main
struct TracerouteApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Traceroute") {
                    showAbout()
                }
            }
            
            CommandGroup(replacing: .help) {
                Button("Check for Updates...") {
                    checkForUpdates()
                }
            }
        }
    }
    
    private func showAbout() {
        let config = AppConfiguration.current
        let alert = NSAlert()
        alert.messageText = "Traceroute"
        alert.informativeText = """
        Version \(config.version) (Build \(config.buildNumber))
        
        A cyberpunk-styled network path analyzer with Little Snitch integration.
        
        © 2025 The Lucky Clover
        """
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    private func checkForUpdates() {
        if let url = AppConfiguration.current.updateURL {
            NSWorkspace.shared.open(url)
        }
    }
}
