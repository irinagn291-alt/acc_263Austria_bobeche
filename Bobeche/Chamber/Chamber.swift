import Foundation

/// Role: Chamber. Canonical walk: Reflect 90s, Breathe 120s, Ambient 90s. Ambient is procedural glow.
enum ChamberKind: String, CaseIterable, Equatable, Sendable, Comparable {
    case reflect
    case breathe
    case ambient

    static let reflectSeconds: TimeInterval = 90
    static let breatheSeconds: TimeInterval = 120
    static let ambientSeconds: TimeInterval = 90

    /// Ambient has no bundled audio file. The third chamber is procedural glow.
    static let bundledAudioFile: String? = nil

    var duration: TimeInterval {
        switch self {
        case .reflect: Self.reflectSeconds
        case .breathe: Self.breatheSeconds
        case .ambient: Self.ambientSeconds
        }
    }

    var usesProceduralGlow: Bool {
        self == .ambient
    }

    var sortIndex: Int {
        switch self {
        case .reflect: 0
        case .breathe: 1
        case .ambient: 2
        }
    }

    static func < (lhs: ChamberKind, rhs: ChamberKind) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }
}

/// Role: Chamber. One Cue Latch or Skip Hollow on a chamber. Forward walk only.
enum ChamberSeal: Equatable, Sendable {
    case latch(Latch)
    case hollow(Hollow)

    var isLatch: Bool {
        if case .latch = self { return true }
        return false
    }

    var isHollow: Bool {
        if case .hollow = self { return true }
        return false
    }

    var chamber: ChamberKind {
        switch self {
        case .latch(let latch): latch.chamber
        case .hollow(let hollow): hollow.chamber
        }
    }
}

/// Role: Chamber. Fold of tonight's seals along one wick. Open chamber is the only live slot.
struct ChamberWalk: Equatable, Sendable {
    var flame: Flame
    var open: ChamberKind?
    var openedUnix: Double?
    var seals: [ChamberSeal]
    var line: String?

    var latchCount: Int {
        seals.filter(\.isLatch).count
    }

    var hollowCount: Int {
        seals.filter(\.isHollow).count
    }

    var isComplete: Bool {
        seals.count >= ChamberKind.allCases.count && open == nil
    }
}
