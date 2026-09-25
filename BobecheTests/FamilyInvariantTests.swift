import XCTest
@testable import Bobeche

/// Family invariant: Canonical order. Durations 90/120/90s. Skip allowed. Cue at elapsed.
/// Procedural ambient, not shipped audio. Streak on completed nights.
final class FamilyInvariantTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        value.locale = Locale(identifier: "en_US_POSIX")
        return value
    }

    func test_canonicalOrderAndDurations() {
        XCTAssertEqual(ChamberKind.allCases, [.reflect, .breathe, .ambient])
        XCTAssertEqual(ChamberKind.reflect.duration, 90)
        XCTAssertEqual(ChamberKind.breathe.duration, 120)
        XCTAssertEqual(ChamberKind.ambient.duration, 90)
        XCTAssertEqual(ChamberKind.reflectSeconds, 90)
        XCTAssertEqual(ChamberKind.breatheSeconds, 120)
        XCTAssertEqual(ChamberKind.ambientSeconds, 90)
    }

    func test_skipAllowedAndCueAtElapsed() throws {
        let now = instant(2026, 9, 17, hour: 21)
        var taper = Taper.dark
        taper = try taper.lightTaper(now: now, calendar: calendar)
        XCTAssertEqual(taper.openChamber, .reflect)

        XCTAssertThrowsError(try taper.cueAtElapsed(89.9, now: now)) { error in
            XCTAssertEqual(error as? WickFault, .notElapsed)
        }
        XCTAssertTrue(taper.canSkip)

        taper = try taper.skipChamber(now: now)
        XCTAssertEqual(taper.openChamber, .breathe)
        XCTAssertEqual(taper.walkSeals.count, 1)
        XCTAssertTrue(taper.walkSeals[0].isHollow)

        taper = try taper.cueAtElapsed(120, now: now.addingTimeInterval(120))
        XCTAssertEqual(taper.openChamber, .ambient)
        XCTAssertTrue(taper.walkSeals[1].isLatch)

        taper = try taper.cueAtElapsed(90, now: now.addingTimeInterval(210))
        guard case .ready = taper else {
            return XCTFail("third Cue must leave the taper Ready")
        }
    }

    func test_ambientIsProceduralNotShippedAudio() {
        XCTAssertTrue(ChamberKind.ambient.usesProceduralGlow)
        XCTAssertNil(ChamberKind.bundledAudioFile)
        XCTAssertFalse(ChamberKind.reflect.usesProceduralGlow)
        XCTAssertFalse(ChamberKind.breathe.usesProceduralGlow)
        XCTAssertTrue(Cue.latches(elapsed: 90, duration: 90))
        XCTAssertFalse(Cue.latches(elapsed: 89, duration: 90))
        XCTAssertTrue(Cue.latches(elapsed: 120, duration: 120))
    }

    func test_streakOnCompletedNightMarks() {
        let day1 = WickDay.from(instant(2026, 9, 14), calendar: calendar)
        let day2 = WickDay.from(instant(2026, 9, 15), calendar: calendar)
        let day3 = WickDay.from(instant(2026, 9, 16), calendar: calendar)
        let marks = [
            NightMark(id: UUID(), day: day1, snuffedUnix: 1, latchCount: 3, hollowCount: 0, line: nil),
            NightMark(id: UUID(), day: day2, snuffedUnix: 2, latchCount: 2, hollowCount: 1, line: nil),
            NightMark(id: UUID(), day: day3, snuffedUnix: 3, latchCount: 3, hollowCount: 0, line: nil),
        ]
        XCTAssertEqual(WickStreak.current(marks: marks, unlits: [], calendar: calendar), 3)

        let miss = Unlit(id: UUID(), day: WickDay.from(instant(2026, 9, 17), calendar: calendar), atUnix: 4)
        XCTAssertEqual(WickStreak.current(marks: marks, unlits: [miss], calendar: calendar), 0)
    }

    private func instant(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = hour
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
