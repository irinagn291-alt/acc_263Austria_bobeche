import XCTest
@testable import Bobeche

@MainActor
final class WickWatchTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        value.locale = Locale(identifier: "en_US_POSIX")
        return value
    }

    func test_reviewKeysOpenThreeSegments() async {
        let now = instant(2026, 9, 17, hour: 21)
        let ledger = TaperSeed.ledger(now: now, calendar: calendar)
        let watch = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            calendar: calendar,
            now: { now },
            shouldLoad: false,
            permitSeed: false
        )
        await watch.appear(arguments: ["-ReviewScreen", "today"])
        XCTAssertEqual(watch.segment, .ritual)
        XCTAssertEqual(watch.ritualLoad, .populated)
        XCTAssertTrue(watch.canSnuff)

        let log = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            calendar: calendar,
            now: { now },
            shouldLoad: false,
            permitSeed: false
        )
        await log.appear(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(log.segment, .history)
        XCTAssertEqual(log.historyLoad, .populated)
        XCTAssertNotEqual(log.segment, watch.segment)

        let goals = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            calendar: calendar,
            now: { now },
            shouldLoad: false,
            permitSeed: false
        )
        await goals.appear(arguments: ["-ReviewScreen", "goals"])
        XCTAssertEqual(goals.segment, .settings)
        XCTAssertEqual(goals.settingsLoad, .populated)
        XCTAssertNotEqual(goals.segment, log.segment)
        XCTAssertNotEqual(goals.segment, watch.segment)
    }

    func test_emptyPopulatedAndFaultLoads() {
        var empty = TaperLedger.empty
        empty.onboardingComplete = true
        let vacant = WickWatch(
            store: TaperHold(ledger: empty),
            ledger: empty,
            shouldLoad: false,
            permitSeed: false
        )
        XCTAssertEqual(vacant.ritualLoad, .empty)
        XCTAssertEqual(vacant.historyLoad, .empty)
        XCTAssertEqual(vacant.settingsLoad, .empty)
        XCTAssertTrue(vacant.canLight)
        XCTAssertTrue(vacant.canSnuff)

        let seeded = WickWatch.previewSeeded(now: instant(2026, 9, 17, hour: 21), calendar: calendar)
        XCTAssertEqual(seeded.ritualLoad, .populated)
        XCTAssertTrue(seeded.canSnuff)
        XCTAssertEqual(seeded.liveVerb, .snuff)
        XCTAssertEqual(seeded.jobTitle, "Snuff the taper")
        XCTAssertGreaterThanOrEqual(seeded.ledger.nightMarks.count, 4)

        let broken = WickWatch(
            store: TaperHold(ledger: empty, warning: .startedEmpty),
            ledger: empty,
            warning: .startedEmpty,
            shouldLoad: false,
            permitSeed: false
        )
        XCTAssertEqual(broken.ritualLoad, .fault)
        XCTAssertEqual(broken.historyLoad, .fault)
        XCTAssertEqual(broken.settingsLoad, .fault)
    }

    func test_watchFoldsLightCueSkipSnuffWithoutAView() async {
        let now = instant(2026, 9, 17, hour: 21)
        var ledger = TaperLedger.empty
        ledger.onboardingComplete = true
        let watch = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            calendar: calendar,
            now: { now },
            shouldLoad: false,
            permitSeed: false
        )
        await watch.lightTaper()
        XCTAssertEqual(watch.openChamber, .reflect)
        XCTAssertEqual(watch.liveVerb, .cue)
        XCTAssertFalse(watch.canCue(elapsed: 30))

        await watch.cueAtElapsed(30)
        XCTAssertEqual(watch.fault, "Cue waits until the chamber is due.")
        XCTAssertEqual(watch.openChamber, .reflect)

        await watch.skipChamber()
        XCTAssertNil(watch.fault)
        XCTAssertEqual(watch.openChamber, .breathe)
        XCTAssertEqual(watch.ledger.hollows.count, 1)

        await watch.cueAtElapsed(120)
        XCTAssertEqual(watch.openChamber, .ambient)
        await watch.cueAtElapsed(90)
        XCTAssertTrue(watch.canSnuff)
        XCTAssertEqual(watch.liveVerb, .snuff)

        await watch.snuffTaper()
        guard case .snuffed(.nightMark) = watch.ledger.taper else {
            return XCTFail("Snuff on Ready must file a NightMark")
        }
        XCTAssertEqual(watch.snuffTick, 1)
        XCTAssertEqual(watch.ledger.nightMarks.count, 1)
        XCTAssertEqual(watch.streak, 1)
    }

    func test_hookWaitsForOnboarding() async {
        var ledger = TaperLedger.empty
        ledger.onboardingComplete = false
        let watch = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            shouldLoad: false,
            permitSeed: false
        )
        await watch.appear(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(watch.segment, .ritual)
        XCTAssertTrue(watch.showsOnboarding)

        await watch.finishOnboarding(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(watch.segment, .history)
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
