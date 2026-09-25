import Foundation

/// Role: Taper. Typed refusals of light, Cue, Skip, Snuff, and Line. Views map these; they never mutate Taper.
enum WickFault: Error, Equatable, Sendable {
    case notDark
    case notLit
    case notElapsed
    case stillWalking
    case alreadyFrozen
    case emptyLine
    case lineNotOnReflect
}

/// Role: Taper. Lighting writes Flame and opens Reflect.
struct Flame: Equatable, Sendable, Identifiable {
    var id: UUID
    var day: WickDay
    var litUnix: Double
}

/// Role: Taper. ADT of tonight: Dark, Lit, Ready, Snuffed. The night is a fold over Chambers.
/// Views call lightTaper, cueAtElapsed, skipChamber, and snuffTaper. No second phase enum.
enum Taper: Equatable, Sendable {
    case dark
    case lit(ChamberWalk)
    case ready(ChamberWalk)
    case snuffed(FiledNight)

    var canLight: Bool {
        if case .dark = self { return true }
        return false
    }

    var canSkip: Bool {
        if case .lit(let walk) = self { return walk.open != nil }
        return false
    }

    var canSnuff: Bool {
        switch self {
        case .dark, .ready: true
        default: false
        }
    }

    var openChamber: ChamberKind? {
        if case .lit(let walk) = self { return walk.open }
        return nil
    }

    var walk: ChamberWalk? {
        switch self {
        case .lit(let walk), .ready(let walk):
            return walk
        case .snuffed(.nightMark(_, let walk)):
            return walk
        default:
            return nil
        }
    }

    var walkSeals: [ChamberSeal] {
        walk?.seals ?? []
    }

    var line: String? {
        walk?.line
    }

    func canCue(elapsed: TimeInterval) -> Bool {
        guard let open = openChamber else { return false }
        return Cue.latches(elapsed: elapsed, duration: open.duration)
    }

    func lightTaper(now: Date, calendar: Calendar, id: UUID = UUID()) throws -> Taper {
        guard case .dark = self else { throw WickFault.notDark }
        let flame = Flame(
            id: id,
            day: WickDay.from(now, calendar: calendar),
            litUnix: now.timeIntervalSince1970
        )
        let walk = ChamberWalk(
            flame: flame,
            open: .reflect,
            openedUnix: flame.litUnix,
            seals: [],
            line: nil
        )
        return .lit(walk)
    }

    func cueAtElapsed(_ elapsed: TimeInterval, now: Date, id: UUID = UUID()) throws -> Taper {
        guard case .lit(let walk) = self, let open = walk.open else {
            throw WickFault.notLit
        }
        guard Cue.latches(elapsed: elapsed, duration: open.duration) else {
            throw WickFault.notElapsed
        }
        let latch = Latch(
            id: id,
            day: walk.flame.day,
            chamber: open,
            elapsed: elapsed,
            atUnix: now.timeIntervalSince1970
        )
        return Self.sealing(.latch(latch), onto: walk, now: now)
    }

    func skipChamber(now: Date, id: UUID = UUID()) throws -> Taper {
        guard case .lit(let walk) = self, let open = walk.open else {
            throw WickFault.notLit
        }
        let hollow = Hollow(
            id: id,
            day: walk.flame.day,
            chamber: open,
            atUnix: now.timeIntervalSince1970
        )
        return Self.sealing(.hollow(hollow), onto: walk, now: now)
    }

    func snuffTaper(now: Date, calendar: Calendar, id: UUID = UUID()) throws -> Taper {
        switch self {
        case .dark:
            let miss = Unlit(
                id: id,
                day: WickDay.from(now, calendar: calendar),
                atUnix: now.timeIntervalSince1970
            )
            return .snuffed(.unlit(miss))
        case .ready(let walk):
            let mark = NightMark(
                id: id,
                day: walk.flame.day,
                snuffedUnix: now.timeIntervalSince1970,
                latchCount: walk.latchCount,
                hollowCount: walk.hollowCount,
                line: walk.line
            )
            return .snuffed(.nightMark(mark, walk))
        case .lit:
            throw WickFault.stillWalking
        case .snuffed:
            throw WickFault.alreadyFrozen
        }
    }

    func writeLine(_ text: String) throws -> Taper {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WickFault.emptyLine }
        switch self {
        case .lit(var walk):
            guard walk.open == .reflect || walk.seals.contains(where: { $0.chamber == .reflect }) else {
                throw WickFault.lineNotOnReflect
            }
            walk.line = trimmed
            return .lit(walk)
        case .ready(var walk):
            walk.line = trimmed
            return .ready(walk)
        default:
            throw WickFault.lineNotOnReflect
        }
    }

    /// Midnight does not auto-snuff. Only a frozen night older than today becomes Dark.
    func restIfNeeded(now: Date, calendar: Calendar) -> Taper {
        guard case .snuffed(let filed) = self else { return self }
        if WickDay.from(now, calendar: calendar) > filed.day {
            return .dark
        }
        return self
    }

    private static func sealing(_ seal: ChamberSeal, onto walk: ChamberWalk, now: Date) -> Taper {
        var next = walk
        next.seals.append(seal)
        if next.seals.count >= ChamberKind.allCases.count {
            next.open = nil
            next.openedUnix = nil
            return .ready(next)
        }
        let kind = ChamberKind.allCases[next.seals.count]
        next.open = kind
        next.openedUnix = now.timeIntervalSince1970
        return .lit(next)
    }
}
