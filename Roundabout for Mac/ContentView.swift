import SwiftUI

struct ContentView: View {
    @State private var cornerRadius: Double = 10.0
    @State private var statusMessage: String = ""
    @State private var isProcessing: Bool = false
    
    @AppStorage("autoQuit") private var autoQuit = false
    @AppStorage("isMenuBarOnly") private var isMenuBarOnly = false

    var body: some View {
        VStack(spacing: 18) {
            Text("Roundabout")
                .font(.headline)

            // Button to return to Dock Mode (Only visible in Menu Bar mode)
            if isMenuBarOnly {
                Button(action: switchToDockMode) {
                    Label("Switch to Dock Mode", systemImage: "macwindow")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }

            // Slider Range (1 to 24)
            HStack {
                Text("1")
                Slider(value: $cornerRadius, in: 1...24, step: 1)
                Text("24")
            }
            .padding(.horizontal)

            Text("Selected Radius: \(Int(cornerRadius))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Era Presets Row
            HStack(spacing: 8) {
                Button("System 1 – Mac OS 9") {
                    cornerRadius = 1
                }
                
                Button("Mac OS X 10.0 – macOS 10.15") {
                    cornerRadius = 4
                }
                
                Button("macOS 11 – macOS 15") {
                    cornerRadius = 10
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            // Action Buttons Stacked Vertically
            VStack(spacing: 10) {
                // Primary Apply Button
                Button(action: applyCornerRadius) {
                    if isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Apply Changes")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isProcessing)

                // Restore Default Button Below
                Button(action: restoreSystemDefaults) {
                    Text("Restore Default")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isProcessing)
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(statusMessage.contains("Failed") ? .red : .green)
            }
        }
        .padding()
        .frame(width: 540, height: isMenuBarOnly ? 340 : 320)
    }

    private func switchToDockMode() {
        isMenuBarOnly = false
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func applyCornerRadius() {
        let radiusValue = Int(cornerRadius)
        let command = """
        defaults write -g NSConvolutionOverride1 -float \(radiusValue) && \
        defaults write -g NSSplitViewItemGlassMinimumCornerRadius -float \(radiusValue) && \
        killall Finder
        """
        executeCommand(command, successMessage: "Applied radius \(radiusValue)! Please close and reopen each app for changes to take full effect.")
    }

    private func restoreSystemDefaults() {
        let command = """
        defaults delete -g NSConvolutionOverride1 2>/dev/null; \
        defaults delete -g NSSplitViewItemGlassMinimumCornerRadius 2>/dev/null; \
        killall Finder
        """
        executeCommand(command, successMessage: "Restored system defaults! Please close and reopen each app for changes to take full effect.")
    }

    private func executeCommand(_ command: String, successMessage: String) {
        isProcessing = true
        statusMessage = ""

        DispatchQueue.global(qos: .userInitiated).async {
            let success = runBackgroundCommand(command)

            DispatchQueue.main.async {
                isProcessing = false
                if success {
                    statusMessage = successMessage
                    
                    if autoQuit {
                        NSApplication.shared.terminate(nil)
                    }
                } else {
                    statusMessage = "Failed to run command. Check Sandbox settings."
                }
            }
        }
    }

    private func runBackgroundCommand(_ command: String) -> Bool {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            print("Error executing process: \(error)")
            return false
        }
    }
}
