import Foundation

/// Role: Cue. Elapsed gate for Latch. Skip does not wait. Views never keep a timer enum.
enum Cue {
    static func latches(elapsed: TimeInterval, duration: TimeInterval) -> Bool {
        elapsed.isFinite && elapsed >= 0 && elapsed >= duration
    }
}
