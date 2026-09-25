import XCTest
@testable import Bobeche

final class WickHookTests: XCTestCase {
    func test_readsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertNil(
            WickHook.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)

        let first = WickHook.consume(
            arguments: ["app", "-ReviewScreen", "log"],
            onboardingComplete: true,
            consumed: &consumed
        )
        XCTAssertEqual(first, .log)
        XCTAssertEqual(first?.segment, .history)
        XCTAssertTrue(consumed)
        XCTAssertNil(
            WickHook.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
    }

    func test_threeKeysAreDistinctScreens() {
        XCTAssertEqual(WickPane.today.rawValue, "today")
        XCTAssertEqual(WickPane.log.rawValue, "log")
        XCTAssertEqual(WickPane.goals.rawValue, "goals")
        XCTAssertNotEqual(WickPane.today, WickPane.log)
        XCTAssertNotEqual(WickPane.log, WickPane.goals)
        XCTAssertNotEqual(WickPane.today, WickPane.goals)
        XCTAssertEqual(WickPane.today.segment, .ritual)
        XCTAssertEqual(WickPane.log.segment, .history)
        XCTAssertEqual(WickPane.goals.segment, .settings)
        XCTAssertNotEqual(WickPane.today.segment, WickPane.log.segment)
        XCTAssertNotEqual(WickPane.log.segment, WickPane.goals.segment)
        XCTAssertNotEqual(WickSegment.ritual, .history)
        XCTAssertNotEqual(WickSegment.history, .settings)

        var consumed = false
        XCTAssertEqual(
            WickHook.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            WickHook.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
    }

    func test_unknownKeyIsIgnored() {
        var consumed = false
        XCTAssertNil(
            WickHook.consume(
                arguments: ["-ReviewScreen", "aura"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertTrue(consumed)
    }
}
