import Foundation

/// Role: Hollow. Skip wrote this seal and walked immediately. Not a destructive miss.
struct Hollow: Equatable, Sendable, Identifiable {
    var id: UUID
    var day: WickDay
    var chamber: ChamberKind
    var atUnix: Double
}
