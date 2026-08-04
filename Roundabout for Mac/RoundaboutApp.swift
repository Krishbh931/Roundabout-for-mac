import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure the dropdown popover
        popover.contentSize = NSSize(width: 540, height: 340)
        popover.behavior = .transient // Automatically hides when clicking anywhere outside!
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Observe preference changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleModeChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        // Apply initial state
        handleModeChange()
    }

    @objc func handleModeChange() {
        let isMenuBarOnly = UserDefaults.standard.bool(forKey: "isMenuBarOnly")

        if isMenuBarOnly {
            // Hide Dock icon
            NSApp.setActivationPolicy(.accessory)

            // Close main standalone app windows
            for window in NSApp.windows {
                if window.className != "NSStatusBarWindow" {
                    window.close()
                }
            }

            // Create Menu Bar item if it doesn't exist
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                if let button = statusItem?.button {
                    button.image = NSImage(systemSymbolName: "square.stack.3d.down.right", accessibilityDescription: "Roundabout")
                    button.action = #selector(togglePopover(_:))
                    button.target = self
                }
            }
        } else {
            // Show Dock icon
            NSApp.setActivationPolicy(.regular)

            // Close popover if currently open
            if popover.isShown {
                popover.performClose(nil)
            }

            // Remove Menu Bar item completely
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }

    // Toggles the popover when clicking the icon
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
