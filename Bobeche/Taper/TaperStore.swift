import Foundation

/// Role: Taper. Preference keys. Snapshot is JSON Data under boc.taper.v1. Demo is Simulator-only.
enum TaperKey {
    static let snapshot = "boc.taper.v1"
    static let backup = "boc.taper.v1.backup"
    static let demo = "boc.demo.v1"
}

/// Role: Taper. Recoverable load outcome. Never crash on a corrupt snapshot. Dark for tonight.
enum WickWarning: Equatable, Sendable {
    case recoveredFromBackup
    case startedEmpty
}

/// Role: Taper. The only persistence seam. Views observe the ledger; they never touch UserDefaults or files.
protocol TaperStoring: Sendable {
    func load(now: Date, calendar: Calendar) async -> (ledger: TaperLedger, warning: WickWarning?)
    func snapshot() async -> TaperLedger
    func lightTaper(now: Date, calendar: Calendar) async throws -> TaperLedger
    func cueAtElapsed(_ elapsed: TimeInterval, now: Date) async throws -> TaperLedger
    func skipChamber(now: Date) async throws -> TaperLedger
    func snuffTaper(now: Date, calendar: Calendar) async throws -> TaperLedger
    func writeLine(_ text: String) async throws -> TaperLedger
    func setOnboardingComplete(_ flag: Bool) async -> TaperLedger
    func flush() async throws
    func resetAllData() async throws
    func seedDemoIfNeeded(permit: Bool, now: Date, calendar: Calendar) async throws -> TaperLedger?
}

extension TaperStoring {
    func load() async -> (ledger: TaperLedger, warning: WickWarning?) {
        await load(now: Date(), calendar: .current)
    }
}

/// Role: Taper. Memory is the source of truth. UserDefaults boc.taper.v1 plus an Application Support file are projections.
actor TaperStore: TaperStoring {
    private let directory: URL
    private let defaultsSuiteName: String?
    private let fileManager: FileManager
    private let writeDelayNanoseconds: UInt64

    private var latest: TaperLedger = .empty
    private var dirty = false
    private var writeTask: Task<Void, Never>?
    private(set) var warning: WickWarning?
    private(set) var lastWriteError: String?

    init(
        directory: URL,
        defaultsSuiteName: String? = nil,
        fileManager: FileManager = .default,
        writeDelayNanoseconds: UInt64 = 300_000_000
    ) {
        self.directory = directory
        self.defaultsSuiteName = defaultsSuiteName
        self.fileManager = fileManager
        self.writeDelayNanoseconds = writeDelayNanoseconds
    }

    static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Bobeche", isDirectory: true)
    }

    func load(now: Date = Date(), calendar: Calendar = .current) async -> (ledger: TaperLedger, warning: WickWarning?) {
        warning = nil
        latest = .empty
        dirty = false
        let defaults = preferenceDefaults()
        if let data = defaults.data(forKey: TaperKey.snapshot), let ledger = decode(data) {
            latest = ledger
            latest.restIfNeeded(now: now, calendar: calendar)
            return (latest, nil)
        }
        if let ledger = decodeFile(fileURL) {
            latest = ledger
            latest.restIfNeeded(now: now, calendar: calendar)
            return (latest, nil)
        }
        if let data = defaults.data(forKey: TaperKey.backup), let ledger = decode(data) {
            latest = ledger
            latest.restIfNeeded(now: now, calendar: calendar)
            warning = .recoveredFromBackup
            return (latest, warning)
        }
        if let ledger = decodeFile(backupURL) {
            latest = ledger
            latest.restIfNeeded(now: now, calendar: calendar)
            warning = .recoveredFromBackup
            return (latest, warning)
        }
        let hadPayload = defaults.data(forKey: TaperKey.snapshot) != nil
            || fileManager.fileExists(atPath: fileURL.path)
        if hadPayload {
            warning = .startedEmpty
        }
        latest.taper = .dark
        return (latest, warning)
    }

    func snapshot() async -> TaperLedger {
        latest
    }

    func lightTaper(now: Date = Date(), calendar: Calendar = .current) async throws -> TaperLedger {
        latest.restIfNeeded(now: now, calendar: calendar)
        try latest.lightTaper(now: now, calendar: calendar)
        try persistCommitted()
        return latest
    }

    func cueAtElapsed(_ elapsed: TimeInterval, now: Date = Date()) async throws -> TaperLedger {
        try latest.cueAtElapsed(elapsed, now: now)
        try persistCommitted()
        return latest
    }

    func skipChamber(now: Date = Date()) async throws -> TaperLedger {
        try latest.skipChamber(now: now)
        try persistCommitted()
        return latest
    }

    func snuffTaper(now: Date = Date(), calendar: Calendar = .current) async throws -> TaperLedger {
        try latest.snuffTaper(now: now, calendar: calendar)
        try persistCommitted()
        return latest
    }

    func writeLine(_ text: String) async throws -> TaperLedger {
        try latest.writeLine(text)
        dirty = true
        scheduleFlush()
        return latest
    }

    func setOnboardingComplete(_ flag: Bool) async -> TaperLedger {
        latest.onboardingComplete = flag
        dirty = true
        scheduleFlush()
        return latest
    }

    func flush() async throws {
        writeTask?.cancel()
        writeTask = nil
        if dirty {
            try persistCommitted()
        }
    }

    func resetAllData() async throws {
        writeTask?.cancel()
        writeTask = nil
        latest = .empty
        dirty = false
        warning = nil
        lastWriteError = nil
        let defaults = preferenceDefaults()
        defaults.removeObject(forKey: TaperKey.snapshot)
        defaults.removeObject(forKey: TaperKey.backup)
        defaults.removeObject(forKey: TaperKey.demo)
        if fileManager.fileExists(atPath: directory.path) {
            try fileManager.removeItem(at: directory)
        }
        prepareDirectory()
    }

    func seedDemoIfNeeded(
        permit: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> TaperLedger? {
        guard permit else { return nil }
        let defaults = preferenceDefaults()
        guard defaults.object(forKey: TaperKey.demo) == nil else { return nil }
        latest = TaperSeed.ledger(now: now, calendar: calendar)
        try persistCommitted()
        defaults.set(true, forKey: TaperKey.demo)
        return latest
    }

    private func persistCommitted() throws {
        let data = try TaperCodec.encode(latest)
        let defaults = preferenceDefaults()
        if let previous = defaults.data(forKey: TaperKey.snapshot) {
            defaults.set(previous, forKey: TaperKey.backup)
        }
        defaults.set(data, forKey: TaperKey.snapshot)
        prepareDirectory()
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try? fileManager.copyItem(at: fileURL, to: backupURL)
        }
        try data.write(to: fileURL, options: .atomic)
        dirty = false
        lastWriteError = nil
    }

    private func scheduleFlush() {
        writeTask?.cancel()
        let delay = writeDelayNanoseconds
        writeTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.flushIfNeeded()
        }
    }

    private func flushIfNeeded() async {
        writeTask = nil
        do {
            if dirty {
                try persistCommitted()
            }
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func decode(_ data: Data) -> TaperLedger? {
        try? TaperCodec.decode(data)
    }

    private func decodeFile(_ url: URL) -> TaperLedger? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    private var fileURL: URL {
        directory.appendingPathComponent("taper.json")
    }

    private var backupURL: URL {
        directory.appendingPathComponent("taper.json.backup")
    }

    private func preferenceDefaults() -> UserDefaults {
        if let defaultsSuiteName {
            return UserDefaults(suiteName: defaultsSuiteName) ?? .standard
        }
        return .standard
    }

    private func prepareDirectory() {
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
}
