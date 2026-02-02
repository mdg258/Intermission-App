# Using Intermission

Complete guide to using the Intermission app for automatic media pause/resume.

## First Launch

### 1. Start the App
- Double-click **Intermission.app** or launch from Xcode
- The app runs in your **menu bar** (top-right of screen)
- Look for a pause circle icon (○)
- **Note**: The app does NOT appear in the Dock

### 2. Grant Permissions

#### Microphone Permission
1. On first launch, macOS will prompt: "Intermission would like to access the microphone"
2. Click **OK** or **Allow**
3. This lets the app listen for your voice

#### Accessibility Permission (Required for keyboard control)
1. Click the Intermission icon in the menu bar
2. You'll see a warning: "Permissions needed"
3. Click **Grant**
4. System Settings will open to **Privacy & Security → Accessibility**
5. Click the **🔒 lock icon** (bottom-left) and enter your password
6. Click the **+** button
7. Navigate to and select **Intermission.app**
8. Ensure the ✅ checkbox next to Intermission is enabled
9. Close System Settings

**Why Accessibility?** The app needs to simulate spacebar presses to pause/resume media.

## Daily Usage

### Starting the Listener

1. **Click the menu bar icon** (○) - The control panel opens
2. **Click "Start Listening"** - The button turns red
3. **Status changes** to "Listening for speech..."
4. **Green indicator** shows the app is active

The app is now monitoring your microphone!

### While Watching Media

1. **Open your media** (Netflix, YouTube, etc.)
2. **Start playing** a video
3. **Talk naturally** - The app detects your voice
4. **Automatic pause** happens after ~250ms of speech
5. **Status shows** "Media paused"
6. **Stop talking** for ~1.2 seconds
7. **Automatic resume** - Video continues playing
8. **Cooldown period** prevents rapid re-pausing

### Stopping the Listener

1. **Click the menu bar icon**
2. **Click "Stop Listening"**
3. The app stops monitoring
4. If media is paused, it will automatically unpause

## Understanding the Interface

### Status Indicator

The colored dot shows the current state:

- **🟢 Green** = Active and listening
- **⚪ Gray** = Inactive (not listening)

### Status Messages

- **"Inactive"** - App is off
- **"Listening for speech..."** - Active, no speech detected
- **"Speech detected"** - Voice heard, building up to pause
- **"Media paused"** - Spacebar pressed, media is paused
- **"Cooldown period"** - Temporary pause before resuming monitoring

### Sensitivity Slider

Adjusts how aggressively the app detects speech:

| Mode | Number | Best For | Behavior |
|------|--------|----------|----------|
| **Quality** | 0 | Quiet rooms | Least sensitive, fewer false positives |
| **Low Bitrate** | 1 | Normal rooms | Balanced sensitivity |
| **Aggressive** | 2 | Active environments | More sensitive (default) |
| **Very Aggressive** | 3 | Noisy environments | Most sensitive, catches all speech |

**When to adjust:**
- **Too many pauses?** → Lower sensitivity (Quality or Low Bitrate)
- **Not detecting your voice?** → Higher sensitivity (Aggressive or Very Aggressive)
- **Background noise triggering?** → Lower sensitivity
- **Soft-spoken or far from mic?** → Higher sensitivity

### Info Section

Displays the app's timing behavior:
- **"Pauses after ~250ms of speech"** - How long you need to talk before pause
- **"Resumes after ~1s of silence"** - How long to stay quiet before resume

## Typical Use Cases

### Watching with a Partner

```
Scenario: You're watching Netflix with your partner

1. Start Intermission
2. Begin watching
3. Partner asks: "Wait, what did they just say?"
   → App pauses after 250ms
4. You discuss the scene
5. Conversation ends, 1.2s of silence
   → App resumes automatically
6. Continue watching
```

### Group Movie Night

```
Scenario: Movie night with 3-4 friends

1. Set sensitivity to "Aggressive" (group conversations)
2. Start Intermission
3. Play the movie
4. Anyone talks → Pause
5. Everyone quiet for 1.2s → Resume
6. Natural pauses during jokes, reactions, etc.
```

### Watching While Eating

```
Scenario: Lunch break, watching YouTube

1. Set sensitivity to "Very Aggressive" (mouth sounds)
2. Start Intermission
3. Play video
4. You comment on the video → Pause
5. Back to eating → Resume
6. Prevents missing content while multitasking
```

## Tips & Tricks

### Optimal Microphone Position
- Keep your MacBook's built-in mic unobstructed
- If using external mic, position ~12-18" away
- Avoid covering the mic with hands or objects

### Best Media Players
Works great with:
- ✅ **Netflix** (web player)
- ✅ **YouTube** (web player)
- ✅ **Disney+** (web player)
- ✅ **Apple TV+**
- ✅ **VLC Media Player**
- ✅ **QuickTime Player**
- ✅ **Plex**
- ✅ Most web-based video players

**Note**: Works with any app that responds to spacebar for pause/play.

### Fine-Tuning Sensitivity

**Problem**: Too many false pauses from background noise
- **Solution**: Lower sensitivity to "Quality" or "Low Bitrate"
- Consider closing the app when not needed

**Problem**: App doesn't detect your voice
- **Solution**: Increase sensitivity to "Very Aggressive"
- Check microphone levels in System Settings → Sound
- Ensure you granted microphone permission

**Problem**: Pauses during brief remarks
- **Expected behavior**: The 250ms threshold should prevent this
- If it still happens, this is by design - even brief speech triggers pause

**Problem**: Resumes too quickly during conversation pauses
- **Note**: Currently set to 1.2s of silence
- This is tunable in the source code (see Customization section in README)

### Multiple Displays
- The app doesn't care which display is active
- As long as the media player is focused, spacebar works
- Consider clicking the media player window before starting

### Keyboard Shortcuts
- **Currently none** - Use the menu bar icon
- Future enhancement: Global hotkey to toggle on/off

## Troubleshooting

### App doesn't pause media

**Check:**
1. Is Accessibility permission granted?
   - System Settings → Privacy & Security → Accessibility
   - Ensure Intermission is listed and checked
2. Is the media player window focused?
   - Click on the Netflix/YouTube window
3. Does spacebar work manually?
   - Try pressing spacebar - if it doesn't pause, the app won't work
4. Is the app actually detecting speech?
   - Watch the status - does it change to "Speech detected"?

### Too sensitive - pauses constantly

**Solutions:**
1. **Lower sensitivity** to "Quality" (0)
2. **Check for background noise**:
   - Fan, AC, music, other people talking
   - Close other apps making sound
3. **Adjust microphone input**:
   - System Settings → Sound → Input
   - Lower input volume slightly
4. **Use headphones** to eliminate speaker feedback

### Not sensitive enough - doesn't detect voice

**Solutions:**
1. **Increase sensitivity** to "Very Aggressive" (3)
2. **Check microphone**:
   - System Settings → Sound → Input
   - Ensure correct mic is selected
   - Check input level bars move when you talk
3. **Test microphone**:
   - Open QuickTime → New Audio Recording
   - Verify mic works
4. **Speak louder or closer** to the mic
5. **Restart the app** (Stop Listening → Start Listening)

### Media resumes while still talking

**This shouldn't happen with the state machine**
- The app only resumes after 1.2s of silence
- Check if you're pausing between words (try talking continuously)
- This could indicate a VAD sensitivity issue - try "Very Aggressive"

### App uses too much CPU

**The app should use ~1-2% CPU**
- If higher, try:
  - Restart the app
  - Check Activity Monitor for other processes
  - Report as a bug (see Contributing in README)

### Permissions keep getting revoked

**macOS sometimes resets permissions**
- Re-grant in System Settings
- Ensure the .app file location doesn't change
- If you rebuild, you may need to re-grant

## Advanced Usage

### Running at Startup

To make Intermission start automatically:

1. Open **System Settings** → **General** → **Login Items**
2. Click the **+** button under "Open at Login"
3. Navigate to and select **Intermission.app**
4. Ensure it's checked in the list

### Keyboard Control (Future Enhancement)

Currently, you must use the menu bar icon. Potential future features:
- Global hotkey to toggle on/off (e.g., `⌘ + Shift + I`)
- Keyboard shortcut to adjust sensitivity
- Quick toggle from anywhere

### Using with Scripts

The app can be controlled via AppleScript (future enhancement):

```applescript
-- Future potential commands
tell application "Intermission"
    activate
    start listening
end tell
```

## Keyboard Shortcuts Reference

| Action | Shortcut | Notes |
|--------|----------|-------|
| Open menu | Click menu bar icon | No keyboard shortcut yet |
| Toggle listening | Click button in UI | No keyboard shortcut yet |
| Adjust sensitivity | Drag slider | No keyboard shortcut yet |

*Note: Keyboard shortcuts are planned for future versions*

## Privacy & Security

### What the app does:
- ✅ Listens to your microphone (when enabled)
- ✅ Processes audio locally on your Mac
- ✅ Simulates spacebar key presses

### What the app does NOT do:
- ❌ Record or save audio
- ❌ Send data to the internet
- ❌ Access your files or documents
- ❌ Track your activity
- ❌ Use cloud services

**Everything happens offline on your Mac.**

## Getting Help

If you encounter issues:

1. **Check permissions** (Microphone + Accessibility)
2. **Restart the app** (Stop → Quit → Relaunch)
3. **Adjust sensitivity**
4. **Check README.md** for troubleshooting
5. **Check BUILD.md** for setup issues

---

**Enjoy seamless conversations during your favorite shows!** 🎬
