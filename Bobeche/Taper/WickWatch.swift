import Foundation
import Observation

/// Role: Taper. Presentation fold over TaperStore. Views call lightTaper, cueAtElapsed,
/// skipChamber, and snuffTaper. They never keep a second phase enum.
@MainActor
@Observable
final class WickWatch {
    let store: any TaperStoring
    var ledger: TaperLedger
    var warning: WickWarning?
    var segment: WickSegment = .ritual
    var fault: String?
    var notice: String?
    var didLoad = false
    var isHauling = false
    var isCommitting = false
    var snuffTick = 0
    var showSuccess = false
    var showLine = false
    var showTwist = false
    var lineDraft = ""

    private var hookConsumed = false
    private var haulToken: UUID?
    private var appeared = false
    private let calendar: Calendar
    private let now: @Sendable () -> Date
    private let shouldLoad: Bool
    private let permitSeed: Bool

    init(
        store: any TaperStoring,
        ledger: TaperLedger = .empty,
        warning: WickWarning? = nil,
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { Date() },
        shouldLoad: Bool = true,
        permitSeed: Bool? = nil
    ) {
        self.store = store
        self.ledger = ledger
        self.warning = warning
        self.calendar = calendar
        self.now = now
        self.shouldLoad = shouldLoad
        self.permitSeed = permitSeed ?? Self.simulatorSeed
    }

    static var simulatorSeed: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    static func live() -> WickWatch {
        let directory: URL
        do {
            directory = try TaperStore.applicationSupportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent(
                "Bobeche",
                isDirectory: true
            )
        }
        return WickWatch(store: TaperStore(directory: directory))
    }

    static func previewSeeded(now: Date = Date(), calendar: Calendar = .current) -> WickWatch {
        let watch = WickWatch(
            store: TaperHold(ledger: TaperSeed.ledger(now: now, calendar: calendar)),
            ledger: TaperSeed.ledger(now: now, calendar: calendar),
            calendar: calendar,
            now: { now },
            shouldLoad: false,
            permitSeed: false
        )
        watch.didLoad = true
        return watch
    }

    static func previewEmpty() -> WickWatch {
        var ledger = TaperLedger.empty
        ledger.onboardingComplete = true
        let watch = WickWatch(
            store: TaperHold(ledger: ledger),
            ledger: ledger,
            shouldLoad: false,
            permitSeed: false
        )
        watch.didLoad = true
        return watch
    }

    var showsOnboarding: Bool {
        didLoad && !ledger.onboardingComplete
    }

    var canLight: Bool { ledger.taper.canLight }
    var canSkip: Bool { ledger.taper.canSkip }
    var canSnuff: Bool { ledger.taper.canSnuff }
    var openChamber: ChamberKind? { ledger.taper.openChamber }
    var walk: ChamberWalk? { ledger.taper.walk }

    var canWriteLine: Bool {
        switch ledger.taper {
        case .lit(let walk):
            return walk.open == .reflect || walk.seals.contains(where: { $0.chamber == .reflect })
        case .ready:
            return true
        default:
            return false
        }
    }

    var ritualLoad: WickLoad {
        if fault != nil, warning == .startedEmpty { return .fault }
        if fault != nil, isBareNight { return .fault }
        if warning == .startedEmpty { return .fault }
        if isBareNight, case .dark = ledger.taper { return .empty }
        return .populated
    }

    var historyLoad: WickLoad {
        if warning == .startedEmpty || (fault != nil && isBareNight) { return .fault }
        if ledger.nightMarks.isEmpty, ledger.latches.isEmpty, ledger.hollows.isEmpty, ledger.unlits.isEmpty {
            return .empty
        }
        return .populated
    }

    var settingsLoad: WickLoad {
        if warning == .startedEmpty { return .fault }
        if isBareNight, case .dark = ledger.taper { return .empty }
        return .populated
    }

    var twistLoad: WickLoad {
        if warning == .startedEmpty { return .fault }
        if ledger.latches.isEmpty, ledger.hollows.isEmpty, ledger.nightMarks.isEmpty {
            return .empty
        }
        return .populated
    }

    var isBareNight: Bool {
        ledger.nightMarks.isEmpty
            && ledger.latches.isEmpty
            && ledger.hollows.isEmpty
            && ledger.unlits.isEmpty
            && ledger.taper.walk == nil
    }

    var streak: Int {
        ledger.streak(calendar: calendar)
    }

    var jobTitle: String {
        switch ledger.taper {
        case .dark:
            return "Light tonight's taper"
        case .lit(let walk):
            switch walk.open {
            case .reflect:
                return "Sit through Reflect"
            case .breathe:
                return "Sit through Breathe"
            case .ambient:
                return "Sit through Ambient"
            case nil:
                return "Keep the walk"
            }
        case .ready:
            return "Snuff the taper"
        case .snuffed(.nightMark):
            return "Tonight is filed"
        case .snuffed(.unlit):
            return "Unlit"
        }
    }

    var jobLine: String {
        switch ledger.taper {
        case .dark:
            return "Reflect, then Breathe, then Ambient. Snuff files the night."
        case .lit(let walk):
            switch walk.open {
            case .reflect:
                return "Cue when the chamber is due. Skip writes a Hollow."
            case .breathe:
                return "Cue at elapsed. Skip walks on."
            case .ambient:
                return "Glow is the room. Cue or Skip, then Snuff."
            case nil:
                return "The wick is still walking."
            }
        case .ready:
            return "Tonight is Ready. Snuff files a NightMark."
        case .snuffed(.nightMark):
            return "History counts NightMarks and Latches."
        case .snuffed(.unlit):
            return "This day does not streak."
        }
    }

    var liveVerb: WickLiveVerb {
        switch ledger.taper {
        case .dark:
            return .light
        case .lit:
            return .cue
        case .ready:
            return .snuff
        case .snuffed:
            return .none
        }
    }

    func canCue(elapsed: TimeInterval) -> Bool {
        ledger.taper.canCue(elapsed: elapsed)
    }

    func elapsed(at date: Date) -> TimeInterval {
        guard case .lit(let walk) = ledger.taper, let opened = walk.openedUnix else { return 0 }
        return max(0, date.timeIntervalSince1970 - opened)
    }

    func remaining(at date: Date) -> TimeInterval {
        guard let open = ledger.taper.openChamber else { return 0 }
        return max(0, open.duration - elapsed(at: date))
    }

    func seal(for kind: ChamberKind) -> ChamberSeal? {
        ledger.taper.walkSeals.first { $0.chamber == kind }
    }

    func appear(arguments: [String] = ProcessInfo.processInfo.arguments) async {
        if appeared {
            applyHook(arguments: arguments)
            return
        }
        appeared = true
        guard shouldLoad else {
            ledger = await store.snapshot()
            didLoad = true
            applyHook(arguments: arguments)
            return
        }
        let token = UUID()
        haulToken = token
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard let self, self.haulToken == token else { return }
            self.isHauling = true
        }
        do {
            _ = try await store.seedDemoIfNeeded(
                permit: permitSeed,
                now: now(),
                calendar: calendar
            )
        } catch {
            fault = "Tonight's taper could not be seeded."
        }
        let loaded = await store.load(now: now(), calendar: calendar)
        ledger = loaded.ledger
        warning = loaded.warning
        applyWarning()
        haulToken = nil
        isHauling = false
        didLoad = true
        applyHook(arguments: arguments)
    }

    func retry() async {
        fault = nil
        notice = nil
        warning = nil
        appeared = false
        didLoad = false
        hookConsumed = false
        await appear()
    }

    func flush() async {
        do {
            try await store.flush()
        } catch {
            fault = "Tonight's taper could not be written."
        }
    }

    func restFromDisk() async {
        let loaded = await store.load(now: now(), calendar: calendar)
        ledger = loaded.ledger
        warning = loaded.warning
        applyWarning()
    }

    func lightTaper() async {
        await commit {
            try await store.lightTaper(now: now(), calendar: calendar)
        }
    }

    func cueAtElapsed(_ elapsed: TimeInterval) async {
        await commit {
            try await store.cueAtElapsed(elapsed, now: now())
        }
    }

    func skipChamber() async {
        await commit {
            try await store.skipChamber(now: now())
        }
    }

    func snuffTaper() async {
        await commit {
            try await store.snuffTaper(now: now(), calendar: calendar)
        }
        if fault == nil, case .snuffed = ledger.taper {
            snuffTick += 1
            showSuccess = true
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                self?.showSuccess = false
            }
        }
    }

    func writeLine() async {
        await commit {
            try await store.writeLine(lineDraft)
        }
        if fault == nil {
            showLine = false
        }
    }

    func finishOnboarding(arguments: [String] = ProcessInfo.processInfo.arguments) async {
        ledger = await store.setOnboardingComplete(true)
        await flush()
        applyHook(arguments: arguments)
    }

    func reopenOnboarding() async {
        ledger = await store.setOnboardingComplete(false)
        segment = .ritual
        showTwist = false
        showLine = false
        await flush()
    }

    func resetAll() async {
        isCommitting = true
        do {
            try await store.resetAllData()
            ledger = await store.snapshot()
            warning = nil
            fault = nil
            notice = nil
            segment = .ritual
            showTwist = false
            showLine = false
            hookConsumed = false
        } catch {
            fault = "Tonight's taper could not be cleared."
        }
        isCommitting = false
    }

    func openLine() {
        lineDraft = ledger.taper.line ?? ""
        showLine = true
    }

    func jumpHistory() {
        segment = .history
        showTwist = false
    }

    func jumpRitual() {
        segment = .ritual
        showTwist = false
    }

    func applyHook(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard let pane = WickHook.consume(
            arguments: arguments,
            onboardingComplete: ledger.onboardingComplete,
            consumed: &hookConsumed
        ) else { return }
        segment = pane.segment
        showTwist = false
        showLine = false
    }

    private func commit(_ work: () async throws -> TaperLedger) async {
        guard !isCommitting else { return }
        isCommitting = true
        defer { isCommitting = false }
        do {
            ledger = try await work()
            fault = nil
        } catch {
            fault = Self.copy(error)
        }
    }

    private func applyWarning() {
        switch warning {
        case .recoveredFromBackup:
            notice = "Restored from a backup copy."
            if fault == "Tonight's taper could not be read." {
                fault = nil
            }
        case .startedEmpty:
            fault = "Tonight's taper could not be read."
            notice = nil
        case nil:
            break
        }
    }

    private static func copy(_ error: Error) -> String {
        switch error as? WickFault {
        case .notDark:
            "The taper is already lit."
        case .notLit:
            "Light the taper first."
        case .notElapsed:
            "Cue waits until the chamber is due."
        case .stillWalking:
            "Finish the walk before you snuff."
        case .alreadyFrozen:
            "Tonight is already filed."
        case .emptyLine:
            "Write one line first."
        case .lineNotOnReflect:
            "Line sits on Reflect only."
        case .none:
            "Tonight's taper could not be updated."
        }
    }
}

enum WickLoad: Equatable, Sendable {
    case empty
    case populated
    case fault
}

enum WickLiveVerb: Equatable, Sendable {
    case light
    case cue
    case snuff
    case none
}
