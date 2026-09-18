import SwiftUI

struct SettingsView: View {
    @AppStorage("autoQuit") private var autoQuit = false
    @AppStorage("isMenuBarOnly") private var isMenuBarOnly = false

    var body: some View {
        TabView {
            // General Preferences Tab
            Form {
                Section {
                    Toggle("Automatically quit after applying changes", isOn: $autoQuit)
                    
                    if #available(macOS 13.0, *) {
                        Toggle("Menu Bar Only Mode (Hide Dock Icon)", isOn: $isMenuBarOnly)
                    } else {
                        HStack {
                            Text("Menu Bar Only Mode")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Requires macOS 13+")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            // About / Credits Tab
            VStack(spacing: 12) {
                // Dynamically displays your main app icon
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)

                Text("Roundabout")
                    .font(.title2)
                    .bold()

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.horizontal)

                VStack(spacing: 6) {
                    Text("Developer: **Krish B.**")
                        .font(.body)

                    Text("Website / Support / GitHub")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Coming Soon")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.secondary.opacity(0.2)))
                }
            }
            .padding(20)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 380, height: 260)
        .onChange(of: isMenuBarOnly) { newValue in
            updateDockVisibility(menuBarOnly: newValue)
        }
    }

    private func updateDockVisibility(menuBarOnly: Bool) {
        if menuBarOnly {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
