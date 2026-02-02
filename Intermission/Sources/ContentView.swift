import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var sensitivity: Double = 2.0
    @State private var isHoveringToggle = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            VStack(spacing: 6) {
                // Custom Logo - Full Width, Zoomed In
                if let logoImage = NSImage(contentsOfFile: "/Users/creativnativ/Desktop/Netflix-Idea/Intermission/new-logo.png") ??
                                   NSImage(contentsOfFile: FileManager.default.currentDirectoryPath + "/new-logo.png") {
                    Image(nsImage: logoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 90)
                        .scaleEffect(1.8)
                        .offset(y: 12)
                        .clipped()
                } else {
                    // Fallback if logo not found
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: "film.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }

                Text("Voice-activated pause")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            VStack(spacing: 12) {
                    // Status Card
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: statusColor.opacity(0.5), radius: 4, x: 0, y: 0)

                                Text(audioManager.isEnabled ? "Active" : "Inactive")
                                    .font(.system(size: 13, weight: .medium))
                            }

                            Spacer()

                            if audioManager.isEnabled {
                                Text(statusText)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                    // Main Toggle Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            audioManager.toggle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(toggleIconBackground)
                                    .frame(width: 40, height: 40)

                                Image(systemName: audioManager.isEnabled ? "stop.fill" : "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(audioManager.isEnabled ? .white : .white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(audioManager.isEnabled ? "Stop Listening" : "Start Listening")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text(audioManager.isEnabled ? "Disable voice detection" : "Enable voice detection")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(isHoveringToggle ? Color.primary.opacity(0.04) : Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHoveringToggle = hovering
                        }
                    }

                    // Sensitivity Control
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label {
                                Text("Sensitivity")
                                    .font(.system(size: 13, weight: .medium))
                            } icon: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 12))
                                    .foregroundColor(.purple)
                            }

                            Spacer()

                            Text(sensitivityLabel)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(sensitivityColor)
                                .cornerRadius(6)
                        }

                        Slider(value: $sensitivity, in: 0...3, step: 1)
                            .tint(.purple)
                            .onChange(of: sensitivity) { newValue in
                                audioManager.setSensitivity(Int(newValue))
                            }

                        HStack {
                            Text("Less Sensitive")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("More Sensitive")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                    // Info Cards
                    VStack(spacing: 6) {
                        InfoRow(icon: "mic.fill", text: "Pauses after ~250ms of speech", color: .blue)
                        InfoRow(icon: "speaker.wave.2.fill", text: "Resumes after ~1s of silence", color: .green)
                    }

                    // Permissions Warning
                    if !audioManager.hasPermissions {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Permissions Required")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Grant microphone & accessibility access")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button("Grant") {
                                audioManager.requestPermissions()
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(12)
        }
        .frame(width: 340, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        audioManager.isEnabled ? .green : .gray
    }

    private var toggleIconBackground: LinearGradient {
        audioManager.isEnabled
            ? LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var sensitivityColor: Color {
        switch Int(sensitivity) {
        case 0: return .green
        case 1: return .blue
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }

    private var statusText: String {
        switch audioManager.state {
        case .idle:
            return "Listening"
        case .speechDetected:
            return "Speech detected"
        case .paused:
            return "Paused"
        case .cooldown:
            return "Cooldown"
        }
    }

    private var sensitivityLabel: String {
        switch Int(sensitivity) {
        case 0: return "Quality"
        case 1: return "Balanced"
        case 2: return "Aggressive"
        case 3: return "Very Aggressive"
        default: return "Normal"
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// Preview removed for command-line build compatibility
// #Preview {
//     ContentView()
// }
