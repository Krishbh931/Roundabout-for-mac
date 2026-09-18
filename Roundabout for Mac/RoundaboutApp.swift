import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure popover for Menu Bar mode
        popover.contentSize = NSSize(width: 540, height: 340)
        popover.behavior = .transient // Automatically dismisses when clicking outside
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Listen for setting updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleModeChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        handleModeChange()
    }

    @objc func handleModeChange() {
        let isMenuBarOnly = UserDefaults.standard.bool(forKey: "isMenuBarOnly")

        if isMenuBarOnly {
            // Hide Dock icon
            NSApp.setActivationPolicy(.accessory)

            // Close standalone app windows so only the popover remains
            for window in NSApp.windows {
                if window.className != "NSStatusBarWindow" {
                    window.close()
                }
            }

            // Create Menu Bar item if it doesn't exist
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                if let button = statusItem?.button {
                    if let originalImage = NSImage(named: "MenuIcon") {
                        // 1. Resize 64x64 asset down to 18x18pt menu bar frame
                        let resizedImage = NSImage(size: NSSize(width: 18, height: 18))
                        resizedImage.lockFocus()
                        originalImage.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18))
                        resizedImage.unlockFocus()
                        
                        // 2. Setting isTemplate to TRUE tells macOS to automatically match system theme
                        // (Black in Light Mode / White in Dark Mode)
                        resizedImage.isTemplate = true
                        button.image = resizedImage
                    } else {
                        // Fallback icon if "MenuIcon" isn't found in Assets
                        button.image = NSImage(systemSymbolName: "square.stack.3d.down.right", accessibilityDescription: "Roundabout")
                    }
                    button.action = #selector(togglePopover(_:))
                    button.target = self
                }
            }
        } else {
            // Restore standard Dock execution mode
            NSApp.setActivationPolicy(.regular)

            if popover.isShown {
                popover.performClose(nil)
            }

            // Remove status bar item
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

@main
struct RoundaboutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }
    }
}
