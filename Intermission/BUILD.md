# Building Intermission

Quick guide to build and run the Intermission app on your Mac.

## Method 1: Using Xcode (Recommended)

This is the easiest method for most users.

### Step 1: Create Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **macOS** → **App**
4. Configure your project:
   - Product Name: `Intermission`
   - Team: Select your development team (or None for local development)
   - Organization Identifier: `com.intermission` (or your preference)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Uncheck "Create Git repository" if already in git

### Step 2: Add Source Files

1. In Xcode's Project Navigator (left sidebar), right-click on the "Intermission" folder
2. Select **Add Files to "Intermission"...**
3. Navigate to the `Intermission/Sources/` directory
4. Select all `.swift` files:
   - `Intermission.swift`
   - `ContentView.swift`
   - `AudioManager.swift`
   - `VADProcessor.swift`
   - `KeyboardSimulator.swift`
5. Ensure **"Copy items if needed"** is checked
6. Click **Add**

### Step 3: Add WebRTC VAD Library

1. Right-click on your project in the navigator
2. Select **New Group** and name it "WebRTCVAD"
3. Right-click on the new group → **Add Files to "Intermission"...**
4. Navigate to `Intermission/WebRTCVAD/`
5. Select both:
   - `webrtc_vad.h`
   - `webrtc_vad.c`
6. Click **Add**

### Step 4: Create Bridging Header

1. Select **File → New → File**
2. Choose **Header File**
3. Name it `Intermission-Bridging-Header.h`
4. Add this content:
   ```objc
   #ifndef Intermission_Bridging_Header_h
   #define Intermission_Bridging_Header_h

   #include "webrtc_vad.h"

   #endif
   ```
5. In your project settings (click on the blue project icon), select your target
6. Go to **Build Settings**
7. Search for "Bridging Header"
8. Set **Objective-C Bridging Header** to: `Intermission/Intermission-Bridging-Header.h`

### Step 5: Configure Info.plist

1. In Project Navigator, click on `Info.plist`
2. Add the following key-value pair:
   - **Key**: `Privacy - Microphone Usage Description`
   - **Value**: `Intermission needs microphone access to detect when you're speaking and automatically pause media playback.`
3. Add another key:
   - **Key**: `Application is agent (UIElement)`
   - **Value**: `YES` (This makes the app run in the menu bar without a dock icon)

### Step 6: Configure Signing & Capabilities

1. Select your project in the navigator
2. Select your target
3. Go to **Signing & Capabilities** tab
4. For local development:
   - **Automatically manage signing**: Checked
   - **Team**: Select your team or "None" for local testing
5. Click **+ Capability** and add:
   - **Hardened Runtime** (expand and enable "Audio Input")

### Step 7: Update App Delegate

1. Delete the auto-generated `IntermissionApp.swift` file (if it exists)
2. Your `Intermission.swift` file already contains the correct app structure

### Step 8: Build and Run

1. Select your Mac as the target device
2. Press **⌘ + R** to build and run
3. The app should appear in your menu bar (top-right corner)

## Method 2: Command Line with Swift Package Manager

If you prefer command-line tools:

```bash
# Navigate to project directory
cd /Users/creativnativ/Desktop/Netflix-Idea/Intermission

# Build in release mode
swift build -c release

# Run the app
.build/release/Intermission
```

**Note**: You may need to configure code signing for distribution builds.

## Method 3: Building a Standalone App

To create a distributable .app bundle:

### Using Xcode

1. In Xcode, select **Product → Archive**
2. When archiving completes, select **Distribute App**
3. Choose **Copy App**
4. Select a destination folder
5. The .app bundle will be created there

### Manual App Bundle Creation

```bash
# Create app bundle structure
mkdir -p Intermission.app/Contents/MacOS
mkdir -p Intermission.app/Contents/Resources

# Build binary
swift build -c release

# Copy binary
cp .build/release/Intermission Intermission.app/Contents/MacOS/

# Copy Info.plist
cp Info.plist Intermission.app/Contents/

# Sign the app (optional, for distribution)
codesign --force --deep --sign - Intermission.app
```

## Granting Permissions

After building, you'll need to grant two permissions:

### 1. Microphone Permission
- Launch the app
- macOS will prompt for microphone access
- Click **OK** or **Allow**

### 2. Accessibility Permission
- Open **System Settings** (⚙️ icon in dock)
- Navigate to **Privacy & Security** → **Accessibility**
- Click the **lock icon** (bottom-left) and authenticate
- Click **+** button
- Find and add **Intermission.app**
- Ensure the checkbox is ✅

## Troubleshooting Build Issues

### "No such module 'AVFoundation'"
- Ensure you're building for macOS, not iOS
- Check that your deployment target is macOS 13.0+

### "Cannot find 'webrtc_vad_create' in scope"
- Ensure the bridging header is correctly configured
- Check that `webrtc_vad.h` is in your project
- Rebuild the project (⌘ + Shift + K to clean, then ⌘ + B to build)

### "Sandbox: ... deny(1) file-read-metadata"
- This can happen with audio permissions
- Go to **Signing & Capabilities** → **App Sandbox**
- Ensure "Audio Input" is enabled

### App builds but doesn't appear
- Check that `LSUIElement` is set to `YES` in Info.plist
- The app appears in the menu bar (top-right), not the Dock
- Look for a pause icon (◯) in your menu bar

### "Code signing error"
- For local development, select "Sign to Run Locally"
- For distribution, you'll need an Apple Developer account

## Next Steps

Once built:
1. Launch the app (it appears in the menu bar)
2. Click the icon to open the control panel
3. Click "Grant" if permissions are needed
4. Click "Start Listening" to activate
5. Open Netflix and start talking!

## Development Tips

### Live Preview in Xcode
- Open `ContentView.swift`
- Click **Resume** in the preview pane (right side)
- UI changes will update live

### Debugging
- Set breakpoints by clicking the line numbers in Xcode
- Use `print()` statements to log to the console
- View console output with **View → Debug Area → Show Debug Area**

### Testing
- Test with different sensitivity levels
- Try various media players (Netflix, YouTube, VLC)
- Test in different noise environments

---

**Happy Building!** 🛠️
