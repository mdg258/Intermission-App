import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var sensitivity: Double = 2.0 // WebRTC VAD mode (0-3)

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "film")
                    .font(.system(size: 32))
                    .foregroundColor(.purple)
                Text("Intermission")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top)

            Divider()

            // Status
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(audioManager.isEnabled ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    Text(audioManager.isEnabled ? "Active" : "Inactive")
                        .font(.headline)
                }

                if audioManager.isEnabled {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Toggle
            Button(action: {
                audioManager.toggle()
            }) {
                HStack {
                    Image(systemName: audioManager.isEnabled ? "stop.circle.fill" : "play.circle.fill")
                    Text(audioManager.isEnabled ? "Stop Listening" : "Start Listening")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(audioManager.isEnabled ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                .foregroundColor(audioManager.isEnabled ? .red : .blue)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            // Sensitivity Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sensitivity")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(sensitivityLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Slider(value: $sensitivity, in: 0...3, step: 1)
                    .onChange(of: sensitivity) { newValue in
                        audioManager.setSensitivity(Int(newValue))
                    }

                HStack {
                    Text("Less")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("More")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Label("Pauses after ~250ms of speech", systemImage: "mic.fill")
                Label("Resumes after ~1s of silence", systemImage: "speaker.wave.2.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // Permissions warning
            if !audioManager.hasPermissions {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Permissions needed")
                        .font(.caption)
                    Button("Grant") {
                        audioManager.requestPermissions()
                    }
                    .font(.caption)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding()
        .frame(width: 320, height: 420)
    }

    private var statusText: String {
        switch audioManager.state {
        case .idle:
            return "Listening for speech..."
        case .speechDetected:
            return "Speech detected"
        case .paused:
            return "Media paused"
        case .cooldown:
            return "Cooldown period"
        }
    }

    private var sensitivityLabel: String {
        switch Int(sensitivity) {
        case 0: return "Quality"
        case 1: return "Low Bitrate"
        case 2: return "Aggressive"
        case 3: return "Very Aggressive"
        default: return "Normal"
        }
    }
}

#Preview {
    ContentView()
}
