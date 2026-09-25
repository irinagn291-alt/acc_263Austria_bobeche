import Foundation

/// Role: Cue. Ritual, History, Settings. One root. No Game segment.
enum WickSegment: String, Equatable, Sendable {
    case ritual
    case history
    case settings
}

/// Role: Cue. Launch keys for live shots. today, log, and goals open three different screens.
enum WickPane: String, Equatable, Sendable {
    case today
    case log
    case goals

    var segment: WickSegment {
        switch self {
        case .today: .ritual
        case .log: .history
        case .goals: .settings
        }
    }
}

/// Role: Cue. Reads ProcessInfo `-ReviewScreen today|log|goals` once after onboarding. No View.
enum WickHook {
    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> WickPane? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return WickPane(rawValue: arguments[next])
    }
}
