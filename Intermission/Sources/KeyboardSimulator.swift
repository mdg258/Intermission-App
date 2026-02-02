import Foundation
import CoreGraphics

/// Simulates keyboard events to control media playback
class KeyboardSimulator {

    /// Simulates a spacebar key press (down and up)
    func pressSpacebar() {
        let keyCode: CGKeyCode = 49 // Spacebar key code

        // Key down event
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
        keyDownEvent?.post(tap: .cghidEventTap)

        // Small delay between down and up
        usleep(50000) // 50ms

        // Key up event
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        keyUpEvent?.post(tap: .cghidEventTap)
    }

    /// Simulates a key press with a specific key code
    func pressKey(_ keyCode: CGKeyCode) {
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
        keyDownEvent?.post(tap: .cghidEventTap)

        usleep(50000)

        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
}

// Common key codes for reference
extension CGKeyCode {
    static let space: CGKeyCode = 49
    static let returnKey: CGKeyCode = 36
    static let escape: CGKeyCode = 53
}
