import XCTest
@testable import Bobeche

/// Architecture: Cue-at-elapsed, Skip-as-Hollow, forward-only walk, NightMark freeze, Unlit with no streak.
/// No View is constructed.
final class TaperFoldTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        value.locale = Locale(identifier: "en_US_POSIX")
        return value
    }

    func test_cueSkipForwardOnlyNightMarkFreezeAndUnlit() throws {
        let night = instant(2026, 9, 16, hour: 21)
        var ledger = TaperLedger.empty

        XCTAssertEqual(ledger.taper, .dark)
        try ledger.lightTaper(now: night, calendar: calendar)
        guard case .lit(let flameWalk) = ledger.taper else {
            return XCTFail("lighting must write Flame and open Reflect")
        }
        XCTAssertEqual(flameWalk.flame.day, WickDay.from(night, calendar: calendar))
        XCTAssertEqual(flameWalk.open, .reflect)
        XCTAssertEqual(flameWalk.seals, [])

        XCTAssertThrowsError(try ledger.cueAtElapsed(0, now: night)) { error in
            XCTAssertEqual(error as? WickFault, .notElapsed)
        }
        XCTAssertEqual(ledger.taper.openChamber, .reflect)

        try ledger.cueAtElapsed(90, now: night.addingTimeInterval(90))
        XCTAssertEqual(ledger.taper.openChamber, .breathe)
        XCTAssertEqual(ledger.latches.count, 1)
        XCTAssertEqual(ledger.latches[0].chamber, .reflect)
        XCTAssertEqual(ledger.latches[0].elapsed, 90)

        try ledger.skipChamber(now: night.addingTimeInterval(100))
        XCTAssertEqual(ledger.taper.openChamber, .ambient)
        XCTAssertEqual(ledger.hollows.count, 1)
        XCTAssertEqual(ledger.hollows[0].chamber, .breathe)
        XCTAssertEqual(ledger.taper.walkSeals.map(\.chamber), [.reflect, .breathe])

        XCTAssertThrowsError(try ledger.snuffTaper(now: night.addingTimeInterval(110), calendar: calendar)) { error in
            XCTAssertEqual(error as? WickFault, .stillWalking)
        }

        try ledger.cueAtElapsed(90, now: night.addingTimeInterval(190))
        guard case .ready = ledger.taper else {
            return XCTFail("third seal must fold to Ready")
        }
        XCTAssertTrue(ledger.taper.canSnuff)
        XCTAssertNil(ledger.taper.openChamber)

        try ledger.snuffTaper(now: night.addingTimeInterval(200), calendar: calendar)
        guard case .snuffed(.nightMark(let mark, let frozen)) = ledger.taper else {
            return XCTFail("Snuff on Ready must write a NightMark and freeze")
        }
        XCTAssertEqual(mark.day, WickDay.from(night, calendar: calendar))
        XCTAssertEqual(mark.latchCount, 2)
        XCTAssertEqual(mark.hollowCount, 1)
        XCTAssertEqual(frozen.seals.count, 3)
        XCTAssertEqual(ledger.nightMarks.count, 1)
        XCTAssertEqual(ledger.streak(calendar: calendar), 1)
        XCTAssertThrowsError(try ledger.cueAtElapsed(90, now: night)) { error in
            XCTAssertEqual(error as? WickFault, .notLit)
        }
        XCTAssertThrowsError(try ledger.snuffTaper(now: night, calendar: calendar)) { error in
            XCTAssertEqual(error as? WickFault, .alreadyFrozen)
        }

        let nextNight = instant(2026, 9, 17, hour: 21)
        ledger.restIfNeeded(now: nextNight, calendar: calendar)
        XCTAssertEqual(ledger.taper, .dark)
        try ledger.snuffTaper(now: nextNight, calendar: calendar)
        guard case .snuffed(.unlit) = ledger.taper else {
            return XCTFail("Snuff on Dark must write Unlit")
        }
        XCTAssertEqual(ledger.unlits.count, 1)
        XCTAssertEqual(ledger.streak(calendar: calendar), 0)
    }

    func test_primaryVerbEmptyPopulatedInvalid() throws {
        let now = instant(2026, 9, 17, hour: 22)
        var empty = Taper.dark
        XCTAssertTrue(empty.canLight)
        XCTAssertTrue(empty.canSnuff)
        empty = try empty.snuffTaper(now: now, calendar: calendar)
        guard case .snuffed(.unlit) = empty else {
            return XCTFail("empty Dark snuff files Unlit")
        }

        var walk = Taper.dark
        walk = try walk.lightTaper(now: now, calendar: calendar)
        XCTAssertFalse(walk.canSnuff)
        XCTAssertThrowsError(try walk.snuffTaper(now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? WickFault, .stillWalking)
        }
        XCTAssertThrowsError(try walk.lightTaper(now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? WickFault, .notDark)
        }
        XCTAssertThrowsError(try walk.cueAtElapsed(30, now: now)) { error in
            XCTAssertEqual(error as? WickFault, .notElapsed)
        }
        XCTAssertThrowsError(try walk.writeLine("   ")) { error in
            XCTAssertEqual(error as? WickFault, .emptyLine)
        }

        walk = try walk.skipChamber(now: now)
        walk = try walk.skipChamber(now: now)
        walk = try walk.skipChamber(now: now)
        guard case .ready = walk else {
            return XCTFail("three skips leave Ready")
        }
        XCTAssertTrue(walk.canSnuff)
        walk = try walk.writeLine("Quiet water.")
        walk = try walk.snuffTaper(now: now, calendar: calendar)
        guard case .snuffed(.nightMark(let mark, _)) = walk else {
            return XCTFail("populated Ready snuff files NightMark")
        }
        XCTAssertEqual(mark.line, "Quiet water.")
        XCTAssertEqual(mark.hollowCount, 3)
        XCTAssertFalse(walk.canSnuff)
    }

    func test_litSurvivesMidnightUntilSnuff() throws {
        let monday = instant(2026, 9, 14, hour: 23)
        var taper = try Taper.dark.lightTaper(now: monday, calendar: calendar)
        let tuesday = instant(2026, 9, 15, hour: 1)
        taper = taper.restIfNeeded(now: tuesday, calendar: calendar)
        guard case .lit(let walk) = taper else {
            return XCTFail("midnight must not auto-snuff a Lit taper")
        }
        XCTAssertEqual(walk.flame.day, WickDay.from(monday, calendar: calendar))
        XCTAssertEqual(walk.open, .reflect)
    }

    func test_seedLeavesSnuffEnabledAndFillsHistory() {
        let now = instant(2026, 9, 17, hour: 21)
        let ledger = TaperSeed.ledger(now: now, calendar: calendar)
        XCTAssertTrue(ledger.onboardingComplete)
        guard case .ready = ledger.taper else {
            return XCTFail("seeded tonight must be Ready")
        }
        XCTAssertTrue(ledger.taper.canSnuff)
        XCTAssertGreaterThanOrEqual(ledger.nightMarks.count, 4)
        XCTAssertGreaterThanOrEqual(ledger.latches.count, 8)
        XCTAssertGreaterThanOrEqual(ledger.hollows.count, 2)
        XCTAssertEqual(ledger.streak(calendar: calendar), 4)
        XCTAssertTrue(ledger.unlits.isEmpty)
    }

    func test_dayKeyIsYYYYMMDDInteger() {
        let late = instant(2026, 8, 31, hour: 23)
        let next = instant(2026, 9, 1, hour: 1)
        XCTAssertEqual(WickDay.from(late, calendar: calendar).rawValue, 20260831)
        XCTAssertEqual(WickDay.from(next, calendar: calendar).rawValue, 20260901)
        XCTAssertEqual(
            WickDay.from(late, calendar: calendar).previous(calendar: calendar)?.rawValue,
            20260830
        )
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
