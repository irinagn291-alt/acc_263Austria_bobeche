import XCTest
@testable import Bobeche

final class TaperStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        value.locale = Locale(identifier: "en_US_POSIX")
        return value
    }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "boc.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    func test_roundTripReloadPreservesReadyWalkAndHistory() async throws {
        let now = instant(2026, 9, 17, hour: 21)
        let store = makeStore()
        _ = try await store.lightTaper(now: now, calendar: calendar)
        _ = try await store.cueAtElapsed(90, now: now.addingTimeInterval(90))
        _ = try await store.skipChamber(now: now.addingTimeInterval(100))
        _ = try await store.cueAtElapsed(90, now: now.addingTimeInterval(190))
        _ = try await store.writeLine("Quiet water.")
        try await store.flush()
        let ready = await store.snapshot()
        guard case .ready = ready.taper else {
            return XCTFail("walk must be Ready before relaunch")
        }

        let relaunched = makeStore()
        let loaded = await relaunched.load(now: now, calendar: calendar)
        XCTAssertNil(loaded.warning)
        guard case .ready(let walk) = loaded.ledger.taper else {
            return XCTFail("relaunch must restore Ready")
        }
        XCTAssertEqual(walk.line, "Quiet water.")
        XCTAssertEqual(walk.latchCount, 2)
        XCTAssertEqual(walk.hollowCount, 1)
        XCTAssertEqual(loaded.ledger.latches.count, 2)
        XCTAssertEqual(loaded.ledger.hollows.count, 1)
        XCTAssertEqual(loaded.ledger.taper.openChamber, nil)
        XCTAssertTrue(loaded.ledger.taper.canSnuff)
        XCTAssertEqual(WickDay.from(now, calendar: calendar).rawValue, 20260917)
    }

    func test_corruptSnapshotFallsBackToBackup() async throws {
        let now = instant(2026, 9, 17, hour: 21)
        let store = makeStore()
        _ = try await store.lightTaper(now: now, calendar: calendar)
        _ = try await store.skipChamber(now: now)
        if let good = defaults.data(forKey: TaperKey.snapshot) {
            defaults.set(good, forKey: TaperKey.backup)
        }
        let file = directory.appendingPathComponent("taper.json")
        let backup = directory.appendingPathComponent("taper.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("{not-json".utf8), forKey: TaperKey.snapshot)
        try Data("{not-json".utf8).write(to: file)

        let loaded = await makeStore().load(now: now, calendar: calendar)
        XCTAssertEqual(loaded.warning, .recoveredFromBackup)
        XCTAssertEqual(loaded.ledger.taper.openChamber, .breathe)
        XCTAssertEqual(loaded.ledger.hollows.count, 1)
    }

    func test_corruptSnapshotWithoutBackupStartsDark() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defaults.set(Data("nope".utf8), forKey: TaperKey.snapshot)
        try Data("nope".utf8).write(to: directory.appendingPathComponent("taper.json"))
        let loaded = await makeStore().load(now: instant(2026, 9, 17), calendar: calendar)
        XCTAssertEqual(loaded.warning, .startedEmpty)
        XCTAssertEqual(loaded.ledger.taper, .dark)
    }

    func test_codecSwitchesOnSchemaVersion() throws {
        let ledger = TaperSeed.ledger(now: instant(2026, 9, 17), calendar: calendar)
        let data = try TaperCodec.encode(ledger)
        let decoded = try TaperCodec.decode(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.nightMarks.count, ledger.nightMarks.count)
        guard case .ready = decoded.taper else {
            return XCTFail("codec must round-trip Ready")
        }

        let future = Data("{\"schemaVersion\":99}".utf8)
        XCTAssertThrowsError(try TaperCodec.decode(future)) { error in
            XCTAssertEqual(error as? TaperCodec.Failure, .unsupportedSchema(99))
        }
        XCTAssertThrowsError(try TaperCodec.decode(Data("[]".utf8))) { error in
            XCTAssertEqual(error as? TaperCodec.Failure, .corrupt)
        }
    }

    func test_resetAllDataClearsSnapshotAndFiles() async throws {
        let store = makeStore()
        _ = try await store.lightTaper(now: instant(2026, 9, 17), calendar: calendar)
        try await store.resetAllData()
        let loaded = await store.load(now: instant(2026, 9, 17), calendar: calendar)
        XCTAssertEqual(loaded.ledger.taper, .dark)
        XCTAssertNil(defaults.data(forKey: TaperKey.snapshot))
        XCTAssertNil(defaults.data(forKey: TaperKey.backup))
        let leftovers = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        XCTAssertTrue(leftovers.filter { $0.pathExtension == "json" }.isEmpty)
    }

    func test_onboardingFlagDebouncesUntilFlush() async throws {
        let store = makeStore()
        _ = try await store.lightTaper(now: instant(2026, 9, 17), calendar: calendar)
        _ = await store.setOnboardingComplete(true)
        try await store.flush()
        let loaded = await makeStore().load(now: instant(2026, 9, 17), calendar: calendar)
        XCTAssertTrue(loaded.ledger.onboardingComplete)
    }

    func test_seedWritesOnceAndEnablesSnuff() async throws {
        let store = makeStore()
        let now = instant(2026, 9, 17, hour: 21)
        let denied = try await store.seedDemoIfNeeded(permit: false, now: now, calendar: calendar)
        XCTAssertNil(denied)

        let first = try await store.seedDemoIfNeeded(permit: true, now: now, calendar: calendar)
        let second = try await store.seedDemoIfNeeded(permit: true, now: now, calendar: calendar)
        XCTAssertNil(second)
        XCTAssertEqual(first?.onboardingComplete, true)
        XCTAssertEqual(first?.taper.canSnuff, true)
        guard case .ready = first?.taper else {
            return XCTFail("seed must leave tonight Ready")
        }
        XCTAssertGreaterThanOrEqual(first?.nightMarks.count ?? 0, 4)
        XCTAssertTrue(defaults.bool(forKey: TaperKey.demo))
        XCTAssertNotNil(defaults.data(forKey: TaperKey.snapshot))
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("taper.json").path)
        )
    }

    private func makeStore() -> TaperStore {
        TaperStore(
            directory: directory,
            defaultsSuiteName: suiteName,
            writeDelayNanoseconds: 0
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
