import Foundation
import AVFoundation
import Combine
import AppKit

enum AppState {
    case idle           // Listening, no speech
    case speechDetected // Speech detected, waiting for threshold
    case paused         // Netflix is paused
    case cooldown       // Cooldown after unpause
}

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    @Published var isEnabled = false
    @Published var state: AppState = .idle
    @Published var hasPermissions = false

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var vadProcessor: VADProcessor?
    private var keyboardSimulator = KeyboardSimulator()

    // State machine timing
    private var speechStartTime: Date?
    private var silenceStartTime: Date?
    private let speechThreshold: TimeInterval = 0.25      // 250ms of speech to pause
    private let silenceThreshold: TimeInterval = 1.2      // 1200ms of silence to resume
    private let cooldownDuration: TimeInterval = 1.5      // 1500ms cooldown
    private var cooldownTimer: Timer?

    // State tracking
    private var isCurrentlyPaused = false

    override private init() {
        super.init()
        checkPermissions()
    }

    func checkPermissions() {
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        hasPermissions = micStatus == .authorized

        // Check accessibility permissions for keyboard simulation
        let trusted = AXIsProcessTrusted()
        hasPermissions = hasPermissions && trusted
    }

    func requestPermissions() {
        // Request microphone permission
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                self?.checkPermissions()
            }
        }

        // For accessibility, open System Preferences
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func toggle() {
        if isEnabled {
            stop()
        } else {
            start()
        }
    }

    func setSensitivity(_ mode: Int) {
        vadProcessor?.setMode(mode)
    }

    private func start() {
        print("🚀 AudioManager: Starting...")
        print("📋 Permissions check - hasPermissions: \(hasPermissions)")

        guard hasPermissions else {
            print("❌ Permissions not granted, requesting...")
            requestPermissions()
            return
        }

        print("✅ Permissions OK, initializing audio engine...")
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            print("❌ Failed to create audio engine")
            return
        }

        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else {
            print("❌ Failed to get input node")
            return
        }

        print("🎤 Input node obtained, initializing VAD...")
        // Initialize VAD processor
        vadProcessor = VADProcessor(sampleRate: 16000)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        print("📊 Recording format: \(recordingFormat)")

        let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                        sampleRate: 16000,
                                        channels: 1,
                                        interleaved: false)

        guard let targetFormat = targetFormat else {
            print("❌ Failed to create target format")
            return
        }

        print("🎧 Installing audio tap...")
        // Install tap
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer, targetFormat: targetFormat)
        }

        do {
            print("▶️ Starting audio engine...")
            try audioEngine.start()
            print("✅ Audio engine started successfully!")
            DispatchQueue.main.async {
                self.isEnabled = true
                self.state = .idle
                print("✅ App is now ACTIVE and listening")
            }
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }

    private func stop() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil

        DispatchQueue.main.async {
            self.isEnabled = false
            self.state = .idle
        }

        // If we're currently paused, unpause
        if isCurrentlyPaused {
            keyboardSimulator.pressSpacebar()
            isCurrentlyPaused = false
        }

        cooldownTimer?.invalidate()
        cooldownTimer = nil
    }

    private var bufferCount = 0

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, targetFormat: AVAudioFormat) {
        bufferCount += 1
        if bufferCount == 1 {
            print("🎵 First audio buffer received! Audio capture is working.")
        }

        // Convert to 16kHz mono if needed
        guard let converter = AVAudioConverter(from: buffer.format, to: targetFormat) else { return }

        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * targetFormat.sampleRate / buffer.format.sampleRate)
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }

        var error: NSError?
        converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        guard error == nil, let channelData = convertedBuffer.int16ChannelData else { return }

        let frameLength = Int(convertedBuffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))

        // Process with VAD
        guard let isSpeech = vadProcessor?.processSamples(samples) else { return }

        DispatchQueue.main.async {
            self.handleVADResult(isSpeech: isSpeech)
        }
    }

    private func handleVADResult(isSpeech: Bool) {
        let now = Date()

        // Debug logging
        if isSpeech {
            print("🎙️ VAD: SPEECH | State: \(state) | Paused: \(isCurrentlyPaused)")
        }

        // Don't process during cooldown
        if state == .cooldown {
            return
        }

        if isSpeech {
            // Speech detected
            silenceStartTime = nil

            if speechStartTime == nil {
                speechStartTime = now
                state = .speechDetected
                print("⏱️ VAD: Started speech timer")
            } else if let start = speechStartTime,
                      now.timeIntervalSince(start) >= speechThreshold,
                      !isCurrentlyPaused {
                // Enough speech detected, pause media
                print("⏸️ VAD: Speech threshold met (\(String(format: "%.2f", now.timeIntervalSince(start)))s), PAUSING media")
                pauseMedia()
            }
        } else {
            // Silence detected
            speechStartTime = nil

            if isCurrentlyPaused {
                if silenceStartTime == nil {
                    silenceStartTime = now
                    print("🔇 VAD: Started silence timer (media is paused)")
                } else if let start = silenceStartTime {
                    let elapsed = now.timeIntervalSince(start)
                    if elapsed >= silenceThreshold {
                        // Enough silence, resume media
                        print("▶️ VAD: Silence threshold met (\(String(format: "%.2f", elapsed))s), RESUMING media")
                        resumeMedia()
                    } else {
                        // Still waiting for silence threshold
                        print("⏳ VAD: Silence ongoing... \(String(format: "%.2f", elapsed))s / \(silenceThreshold)s")
                    }
                }
            } else {
                if state != .idle {
                    state = .idle
                }
            }
        }
    }

    private func pauseMedia() {
        keyboardSimulator.pressSpacebar()
        isCurrentlyPaused = true
        state = .paused
    }

    private func resumeMedia() {
        keyboardSimulator.pressSpacebar()
        isCurrentlyPaused = false
        silenceStartTime = nil

        // Enter cooldown period
        state = .cooldown
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: cooldownDuration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.state = .idle
            }
        }
    }
}
