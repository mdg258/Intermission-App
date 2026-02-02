import Foundation

/// WebRTC VAD wrapper for speech detection
class VADProcessor {
    private var vadHandle: OpaquePointer?
    private let sampleRate: Int
    private var mode: Int = 2 // 0=Quality, 1=Low Bitrate, 2=Aggressive, 3=Very Aggressive

    // Frame sizes in ms that WebRTC VAD supports (10, 20, or 30)
    private let frameDurationMs = 30
    private var frameSize: Int
    private var audioBuffer: [Int16] = []

    init(sampleRate: Int) {
        self.sampleRate = sampleRate
        self.frameSize = (sampleRate * frameDurationMs) / 1000

        // Initialize WebRTC VAD
        vadHandle = webrtc_vad_create()
        if let handle = vadHandle {
            webrtc_vad_init(handle)
            webrtc_vad_set_mode(handle, Int32(mode))
        }
    }

    deinit {
        if let handle = vadHandle {
            webrtc_vad_free(handle)
        }
    }

    func setMode(_ newMode: Int) {
        guard newMode >= 0 && newMode <= 3 else { return }
        mode = newMode
        if let handle = vadHandle {
            webrtc_vad_set_mode(handle, Int32(mode))
        }
    }

    /// Process audio samples and return whether speech is detected
    func processSamples(_ samples: [Int16]) -> Bool {
        guard let handle = vadHandle else { return false }

        // Add samples to buffer
        audioBuffer.append(contentsOf: samples)

        var speechDetected = false

        // Process complete frames
        while audioBuffer.count >= frameSize {
            let frame = Array(audioBuffer.prefix(frameSize))
            audioBuffer.removeFirst(frameSize)

            // Process frame with WebRTC VAD
            let result = frame.withUnsafeBufferPointer { bufferPointer in
                webrtc_vad_process(handle, Int32(sampleRate), bufferPointer.baseAddress, frame.count)
            }

            if result == 1 {
                speechDetected = true
            }
        }

        return speechDetected
    }
}

// MARK: - WebRTC VAD C Interface
// These are placeholder declarations - you'll need to link against the actual WebRTC VAD library

@_silgen_name("webrtc_vad_create")
func webrtc_vad_create() -> OpaquePointer?

@_silgen_name("webrtc_vad_free")
func webrtc_vad_free(_ handle: OpaquePointer)

@_silgen_name("webrtc_vad_init")
func webrtc_vad_init(_ handle: OpaquePointer) -> Int32

@_silgen_name("webrtc_vad_set_mode")
func webrtc_vad_set_mode(_ handle: OpaquePointer, _ mode: Int32) -> Int32

@_silgen_name("webrtc_vad_process")
func webrtc_vad_process(_ handle: OpaquePointer, _ sampleRate: Int32, _ audioFrame: UnsafePointer<Int16>?, _ frameLength: Int) -> Int32
