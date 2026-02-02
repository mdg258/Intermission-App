<p align="center">
  <img src="intermission.png" alt="Intermission Logo" width="400">
</p>

<h1 align="center">Intermission</h1>

<p align="center">
  <strong>Auto-pause your media when you talk. Auto-resume when you're done.</strong>
</p>

<p align="center">
  A modern macOS menu bar app that automatically pauses Netflix, YouTube, and more when you start talking.
  <br>Perfect for watching shows with friends or family - no more fumbling for the pause button!
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-how-to-use">How to Use</a> •
  <a href="#-troubleshooting">Troubleshooting</a> •
  <a href="#-contributing">Contributing</a>
</p>

## ✨ Features

- 🎙️ **Real-time Voice Detection** - Uses WebRTC VAD, not just volume threshold
- 🧠 **Smart State Machine** - Pauses after ~250ms of speech, resumes after ~1.2s of silence
- 🎚️ **Adjustable Sensitivity** - Four levels from Quality to Very Aggressive
- 🖥️ **Menu Bar App** - Clean, unobtrusive interface that stays out of your way
- ⚡ **Fast & Lightweight** - Low latency, minimal CPU usage (~1-2%)
- 🔒 **Privacy First** - All processing happens locally, no data leaves your Mac
- 🎬 **Universal Compatibility** - Works with Netflix, YouTube, VLC, and more

## Screenshots

The app lives in your menu bar with a simple pause icon. Click it to see the control panel with:
- On/Off toggle
- Sensitivity slider
- Real-time status indicator
- Permission management

## 🚀 Quick Start

### What You Need

- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (free from the Mac App Store)

### Installation

#### Option 1: Command Line (Fastest)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/intermission.git
cd intermission

# 2. Build the app
swift build -c release

# 3. Run the app
.build/release/Intermission
```

The app will appear in your menu bar (top-right corner) with a pause icon.

#### Option 2: Xcode (Recommended for Development)

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/intermission.git
   cd intermission
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   ```
   Or double-click `Package.swift` in Finder

3. **Build and Run**
   - Press `⌘ + R` to build and run
   - Or press `⌘ + B` to just build

4. **Look for the icon**
   - The app appears in your menu bar (not the Dock)
   - Click the pause icon to get started

### First-Time Setup

After launching, you'll need to grant two permissions:

#### 1. Microphone Access (Auto-Prompt)
- macOS will ask: "Intermission would like to access the microphone"
- Click **OK**
- This lets the app detect when you're speaking

#### 2. Accessibility Access (Manual Setup)
The app needs this to simulate spacebar presses:

1. Click the Intermission menu bar icon
2. Click **Grant** in the permissions warning
3. System Settings will open automatically
4. Click the **🔒 lock icon** (bottom-left) and enter your password
5. Click the **+** button
6. Find and select **Intermission** (or **Intermission.app**)
7. Make sure the checkbox ✅ is enabled
8. Close System Settings

That's it! Click "Start Listening" and you're ready to go.

## 📖 How to Use

### Basic Usage

1. **Find the app** in your menu bar (pause icon at top-right)
2. **Click the icon** to open the control panel
3. **Click "Start Listening"** - Button turns red when active
4. **Open Netflix** (or YouTube, Disney+, etc.)
5. **Start talking** - Video pauses automatically after ~250ms
6. **Stop talking** - Video resumes after ~1.2 seconds of silence

That's it! The app runs in the background and handles everything automatically.

### Adjusting Sensitivity

If the app is too sensitive or not sensitive enough, use the slider:

| Setting | When to Use |
|---------|-------------|
| **Quality** | Quiet room, minimal background noise |
| **Low Bitrate** | Normal home environment |
| **Aggressive** ⭐ | Default - works for most situations |
| **Very Aggressive** | Noisy room, soft-spoken, or far from mic |

### Status Indicators

The app shows what it's doing:

- 🟢 **"Listening for speech..."** - Active, waiting for you to talk
- 🟡 **"Speech detected"** - Heard you, about to pause
- 🔴 **"Media paused"** - Video is paused
- ⏸️ **"Cooldown period"** - Temporary pause to prevent spam

### What Works

✅ **Tested and works with:**
- Netflix (web browser)
- YouTube (web browser)
- Disney+, Hulu, Prime Video
- VLC Media Player
- QuickTime Player
- Apple TV+
- Plex

Basically any app that pauses/plays with the spacebar!

## 🔧 Troubleshooting

### App doesn't pause my video

**Check permissions:**
1. Go to System Settings → Privacy & Security → Accessibility
2. Make sure Intermission is in the list and ✅ checked
3. If not, click **+** and add it

**Check focus:**
- Click on the video player window before starting
- The media player needs to be the active window

### Too many false pauses

**Lower the sensitivity:**
1. Click the menu bar icon
2. Drag the sensitivity slider to "Quality" or "Low Bitrate"
3. Close windows/apps making background noise

### App doesn't detect my voice

**Increase sensitivity:**
1. Click the menu bar icon
2. Drag sensitivity to "Very Aggressive"
3. Check your mic is working (System Settings → Sound → Input)
4. Speak closer to your Mac's microphone

### App not in menu bar

**If you don't see the pause icon:**
- The app might not have started - check Activity Monitor
- Try rebuilding with Xcode instead of command line
- Code signing may be required - run from Xcode with ⌘+R

### "Permission needed" warning won't go away

**Grant both permissions:**
1. **Microphone**: System Settings → Privacy & Security → Microphone
2. **Accessibility**: System Settings → Privacy & Security → Accessibility
3. Restart the app after granting permissions

### High CPU usage

The app should use ~1-2% CPU. If higher:
- Restart the app
- Check for other audio apps interfering
- File an issue on GitHub if it persists

## How It Works

### Voice Activity Detection
Intermission uses **WebRTC VAD** (Voice Activity Detector), a battle-tested algorithm from Google's WebRTC project. It analyzes:
- **Energy levels** - Detects sound above background noise
- **Zero-crossing rate** - Distinguishes speech from other sounds
- **Temporal patterns** - Tracks energy history for context

Unlike simple volume threshold detection, VAD is specifically designed to detect human speech patterns.

### State Machine
The app uses a sophisticated state machine to prevent false triggers:

```
IDLE → Speech detected (>200ms) → SPEECH_DETECTED
     ↓                                    ↓
   Silence                         Spacebar pressed
     ↓                                    ↓
Continue listening ← COOLDOWN ← PAUSED ← Continue speech
                         ↓           ↓
                    (~1.5s)    Silence (>1.2s)
```

This ensures:
- Brief sounds don't trigger pauses
- Short pauses in conversation don't resume playback
- Rapid pause/resume cycles are prevented

### Keyboard Simulation
The app uses Core Graphics' CGEvent API to simulate spacebar presses, which works universally across:
- Netflix
- YouTube
- Disney+
- Apple TV
- VLC
- QuickTime
- And virtually any media player

## Technical Architecture

```
┌─────────────────────────────────────────────┐
│          SwiftUI Menu Bar App               │
├─────────────────────────────────────────────┤
│  • Intermission.swift (App Entry)           │
│  • ContentView.swift (UI)                   │
│  • AudioManager.swift (Audio Processing)    │
│  • VADProcessor.swift (Voice Detection)     │
│  • KeyboardSimulator.swift (Key Events)     │
└──────────┬──────────────────────────────────┘
           │
           ├──► AVAudioEngine (Audio Capture)
           │
           ├──► WebRTC VAD (C Library)
           │    └─ Energy analysis
           │    └─ Zero-crossing rate
           │    └─ Speech pattern detection
           │
           └──► CoreGraphics (Keyboard Events)
```

## Project Structure

```
Intermission/
├── Package.swift               # Swift Package Manager configuration
├── README.md                  # This file
├── Sources/
│   ├── Intermission.swift     # App entry point & menu bar setup
│   ├── ContentView.swift      # SwiftUI interface
│   ├── AudioManager.swift     # Audio capture & state machine
│   ├── VADProcessor.swift     # WebRTC VAD wrapper
│   └── KeyboardSimulator.swift # Spacebar simulation
└── WebRTCVAD/
    ├── webrtc_vad.h          # C header
    └── webrtc_vad.c          # VAD implementation
```

## Customization

### Adjusting Timing Thresholds
Edit [AudioManager.swift:17-19](Sources/AudioManager.swift#L17-L19):

```swift
private let speechThreshold: TimeInterval = 0.25      // Time before pausing
private let silenceThreshold: TimeInterval = 1.2      // Time before resuming
private let cooldownDuration: TimeInterval = 1.5      // Cooldown period
```

### Changing the Key Press
Edit [KeyboardSimulator.swift:8](Sources/KeyboardSimulator.swift#L8) to use a different key:

```swift
let keyCode: CGKeyCode = 49 // 49 = spacebar, 53 = escape, etc.
```

### Adjusting Audio Processing
Edit [AudioManager.swift:67-70](Sources/AudioManager.swift#L67-L70) to change audio format:

```swift
let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                sampleRate: 16000,  // Change sample rate
                                channels: 1,         // Mono/stereo
                                interleaved: false)
```

## 🎯 Future Enhancements

Potential improvements:
- [ ] App icon and custom design
- [ ] Configurable keyboard shortcuts
- [ ] Support for media keys instead of spacebar
- [ ] Detection history visualization
- [ ] Export settings/profiles
- [ ] Alternative VAD engines (Silero VAD for even better accuracy)
- [ ] Multi-language speech detection
- [ ] Training mode to calibrate for your voice

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Report Issues
Found a bug? Have a feature request?
1. Check [existing issues](https://github.com/YOUR_USERNAME/intermission/issues)
2. Create a new issue with details about:
   - What happened vs. what you expected
   - Steps to reproduce
   - Your macOS version
   - Screenshots if relevant

### Submit Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Ideas for Contributions
- 🎨 Better VAD implementation (full WebRTC VAD or Silero)
- 🎨 UI/UX enhancements and app icon design
- ⌨️ Global keyboard shortcuts
- 📊 Detection history visualization
- 🧪 Test coverage
- 📝 Documentation improvements

## 📄 License

This project is provided as-is for personal use. Feel free to modify and adapt for your needs.

**MIT License** - See LICENSE file for details (if you add one)

## 🙏 Acknowledgments

- **WebRTC VAD** - Google's Voice Activity Detection algorithm
- **SwiftUI** - Apple's modern UI framework
- **AVFoundation** - Apple's audio processing framework

---

<div align="center">

### Quick Links

[📥 Download](https://github.com/YOUR_USERNAME/intermission/releases) • [🐛 Report Bug](https://github.com/YOUR_USERNAME/intermission/issues) • [💡 Request Feature](https://github.com/YOUR_USERNAME/intermission/issues) • [📖 Documentation](BUILD.md)

**Made with ❤️ for seamless binge-watching**

*Enjoy uninterrupted conversations while watching your favorite shows!* 🎬🗣️

</div>
