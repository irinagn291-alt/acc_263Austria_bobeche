import Foundation

/// Role: Latch. Cue at elapsed wrote this seal and opened the next chamber.
struct Latch: Equatable, Sendable, Identifiable {
    var id: UUID
    var day: WickDay
    var chamber: ChamberKind
    var elapsed: TimeInterval
    var atUnix: Double
}
