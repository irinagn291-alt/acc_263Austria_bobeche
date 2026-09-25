import Foundation

/// Role: Taper. Codable root projection lives in the codec. Memory holds this ledger.
struct TaperLedger: Equatable, Sendable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var taper: Taper
    var latches: [Latch]
    var hollows: [Hollow]
    var nightMarks: [NightMark]
    var unlits: [Unlit]

    static let empty = TaperLedger(
        schemaVersion: TaperCodec.currentSchema,
        onboardingComplete: false,
        taper: .dark,
        latches: [],
        hollows: [],
        nightMarks: [],
        unlits: []
    )

    var latchCount: Int { latches.count }
    var hollowCount: Int { hollows.count }
    var nightMarkCount: Int { nightMarks.count }

    func streak(calendar: Calendar) -> Int {
        WickStreak.current(marks: nightMarks, unlits: unlits, calendar: calendar)
    }

    mutating func restIfNeeded(now: Date, calendar: Calendar) {
        taper = taper.restIfNeeded(now: now, calendar: calendar)
    }

    mutating func lightTaper(now: Date, calendar: Calendar, id: UUID = UUID()) throws {
        taper = try taper.lightTaper(now: now, calendar: calendar, id: id)
    }

    mutating func cueAtElapsed(_ elapsed: TimeInterval, now: Date, id: UUID = UUID()) throws {
        let prior = taper.walkSeals.count
        taper = try taper.cueAtElapsed(elapsed, now: now, id: id)
        absorbSeals(after: prior)
    }

    mutating func skipChamber(now: Date, id: UUID = UUID()) throws {
        let prior = taper.walkSeals.count
        taper = try taper.skipChamber(now: now, id: id)
        absorbSeals(after: prior)
    }

    mutating func snuffTaper(now: Date, calendar: Calendar, id: UUID = UUID()) throws {
        taper = try taper.snuffTaper(now: now, calendar: calendar, id: id)
        if case .snuffed(let filed) = taper {
            switch filed {
            case .nightMark(let mark, _):
                nightMarks.append(mark)
            case .unlit(let miss):
                unlits.append(miss)
            }
        }
    }

    mutating func writeLine(_ text: String) throws {
        taper = try taper.writeLine(text)
    }

    private mutating func absorbSeals(after priorCount: Int) {
        let seals = taper.walkSeals
        guard priorCount < seals.count else { return }
        for seal in seals[priorCount...] {
            switch seal {
            case .latch(let latch):
                latches.append(latch)
            case .hollow(let hollow):
                hollows.append(hollow)
            }
        }
    }
}
