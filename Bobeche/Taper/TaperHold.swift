import Foundation

/// Role: Taper. In-memory taper for previews and tests. Views never see this type.
actor TaperHold: TaperStoring {
    private var latest: TaperLedger
    private var warning: WickWarning?

    init(ledger: TaperLedger = .empty, warning: WickWarning? = nil) {
        self.latest = ledger
        self.warning = warning
    }

    func load(now: Date, calendar: Calendar) async -> (ledger: TaperLedger, warning: WickWarning?) {
        latest.restIfNeeded(now: now, calendar: calendar)
        return (latest, warning)
    }

    func snapshot() async -> TaperLedger {
        latest
    }

    func lightTaper(now: Date, calendar: Calendar) async throws -> TaperLedger {
        latest.restIfNeeded(now: now, calendar: calendar)
        try latest.lightTaper(now: now, calendar: calendar)
        return latest
    }

    func cueAtElapsed(_ elapsed: TimeInterval, now: Date) async throws -> TaperLedger {
        try latest.cueAtElapsed(elapsed, now: now)
        return latest
    }

    func skipChamber(now: Date) async throws -> TaperLedger {
        try latest.skipChamber(now: now)
        return latest
    }

    func snuffTaper(now: Date, calendar: Calendar) async throws -> TaperLedger {
        try latest.snuffTaper(now: now, calendar: calendar)
        return latest
    }

    func writeLine(_ text: String) async throws -> TaperLedger {
        try latest.writeLine(text)
        return latest
    }

    func setOnboardingComplete(_ flag: Bool) async -> TaperLedger {
        latest.onboardingComplete = flag
        return latest
    }

    func flush() async throws {}

    func resetAllData() async throws {
        latest = .empty
        warning = nil
    }

    func seedDemoIfNeeded(permit: Bool, now: Date, calendar: Calendar) async throws -> TaperLedger? {
        guard permit else { return nil }
        latest = TaperSeed.ledger(now: now, calendar: calendar)
        return latest
    }
}
