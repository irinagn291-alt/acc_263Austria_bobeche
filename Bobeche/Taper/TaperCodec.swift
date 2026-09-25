import Foundation

/// Role: Taper. schemaVersion switch and ledger ↔ JSON mapping. UserDefaults never sees Taper raw.
enum TaperCodec {
    static let currentSchema = 1

    enum Failure: Error, Equatable {
        case unsupportedSchema(Int)
        case corrupt
    }

    static func encode(_ ledger: TaperLedger) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(RootDocument.from(ledger))
    }

    static func decode(_ data: Data) throws -> TaperLedger {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw Failure.corrupt
        }
        switch probe.schemaVersion {
        case 1:
            do {
                return try decoder.decode(RootDocument.self, from: data).asLedger()
            } catch let failure as Failure {
                throw failure
            } catch {
                throw Failure.corrupt
            }
        default:
            throw Failure.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}

private struct RootDocument: Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var taper: TaperDocument
    var latches: [LatchDocument]
    var hollows: [HollowDocument]
    var nightMarks: [NightMarkDocument]
    var unlits: [UnlitDocument]

    static func from(_ ledger: TaperLedger) -> RootDocument {
        RootDocument(
            schemaVersion: TaperCodec.currentSchema,
            onboardingComplete: ledger.onboardingComplete,
            taper: TaperDocument.from(ledger.taper),
            latches: ledger.latches.map(LatchDocument.init(latch:)),
            hollows: ledger.hollows.map(HollowDocument.init(hollow:)),
            nightMarks: ledger.nightMarks.map(NightMarkDocument.init(mark:)),
            unlits: ledger.unlits.map(UnlitDocument.init(miss:))
        )
    }

    func asLedger() throws -> TaperLedger {
        TaperLedger(
            schemaVersion: schemaVersion,
            onboardingComplete: onboardingComplete,
            taper: try taper.asTaper(),
            latches: try latches.map { try $0.asLatch() },
            hollows: try hollows.map { try $0.asHollow() },
            nightMarks: nightMarks.map { $0.asMark() },
            unlits: unlits.map { $0.asUnlit() }
        )
    }
}

private struct TaperDocument: Codable {
    var kind: String
    var walk: WalkDocument?
    var filed: FiledDocument?

    static func from(_ taper: Taper) -> TaperDocument {
        switch taper {
        case .dark:
            return TaperDocument(kind: "dark", walk: nil, filed: nil)
        case .lit(let walk):
            return TaperDocument(kind: "lit", walk: WalkDocument.from(walk), filed: nil)
        case .ready(let walk):
            return TaperDocument(kind: "ready", walk: WalkDocument.from(walk), filed: nil)
        case .snuffed(let filed):
            return TaperDocument(kind: "snuffed", walk: nil, filed: FiledDocument.from(filed))
        }
    }

    func asTaper() throws -> Taper {
        switch kind {
        case "dark":
            return .dark
        case "lit":
            guard let walk else { throw TaperCodec.Failure.corrupt }
            return .lit(try walk.asWalk())
        case "ready":
            guard let walk else { throw TaperCodec.Failure.corrupt }
            return .ready(try walk.asWalk())
        case "snuffed":
            guard let filed else { throw TaperCodec.Failure.corrupt }
            return .snuffed(try filed.asFiled())
        default:
            throw TaperCodec.Failure.corrupt
        }
    }
}

private struct FiledDocument: Codable {
    var kind: String
    var mark: NightMarkDocument?
    var miss: UnlitDocument?
    var walk: WalkDocument?

    static func from(_ filed: FiledNight) -> FiledDocument {
        switch filed {
        case .nightMark(let mark, let walk):
            return FiledDocument(
                kind: "nightMark",
                mark: NightMarkDocument(mark: mark),
                miss: nil,
                walk: WalkDocument.from(walk)
            )
        case .unlit(let miss):
            return FiledDocument(
                kind: "unlit",
                mark: nil,
                miss: UnlitDocument(miss: miss),
                walk: nil
            )
        }
    }

    func asFiled() throws -> FiledNight {
        switch kind {
        case "nightMark":
            guard let mark, let walk else { throw TaperCodec.Failure.corrupt }
            return .nightMark(mark.asMark(), try walk.asWalk())
        case "unlit":
            guard let miss else { throw TaperCodec.Failure.corrupt }
            return .unlit(miss.asUnlit())
        default:
            throw TaperCodec.Failure.corrupt
        }
    }
}

private struct WalkDocument: Codable {
    var flame: FlameDocument
    var open: String?
    var openedUnix: Double?
    var seals: [SealDocument]
    var line: String?

    static func from(_ walk: ChamberWalk) -> WalkDocument {
        WalkDocument(
            flame: FlameDocument(flame: walk.flame),
            open: walk.open?.rawValue,
            openedUnix: walk.openedUnix,
            seals: walk.seals.map(SealDocument.from),
            line: walk.line
        )
    }

    func asWalk() throws -> ChamberWalk {
        let openKind: ChamberKind?
        if let open {
            guard let kind = ChamberKind(rawValue: open) else { throw TaperCodec.Failure.corrupt }
            openKind = kind
        } else {
            openKind = nil
        }
        return ChamberWalk(
            flame: flame.asFlame(),
            open: openKind,
            openedUnix: openedUnix,
            seals: try seals.map { try $0.asSeal() },
            line: line
        )
    }
}

private struct FlameDocument: Codable {
    var id: UUID
    var day: Int
    var litUnix: Double

    init(flame: Flame) {
        id = flame.id
        day = flame.day.rawValue
        litUnix = flame.litUnix
    }

    func asFlame() -> Flame {
        Flame(id: id, day: WickDay(rawValue: day), litUnix: litUnix)
    }
}

private struct SealDocument: Codable {
    var kind: String
    var latch: LatchDocument?
    var hollow: HollowDocument?

    static func from(_ seal: ChamberSeal) -> SealDocument {
        switch seal {
        case .latch(let latch):
            return SealDocument(kind: "latch", latch: LatchDocument(latch: latch), hollow: nil)
        case .hollow(let hollow):
            return SealDocument(kind: "hollow", latch: nil, hollow: HollowDocument(hollow: hollow))
        }
    }

    func asSeal() throws -> ChamberSeal {
        switch kind {
        case "latch":
            guard let latch else { throw TaperCodec.Failure.corrupt }
            return .latch(try latch.asLatch())
        case "hollow":
            guard let hollow else { throw TaperCodec.Failure.corrupt }
            return .hollow(try hollow.asHollow())
        default:
            throw TaperCodec.Failure.corrupt
        }
    }
}

private struct LatchDocument: Codable {
    var id: UUID
    var day: Int
    var chamber: String
    var elapsed: Double
    var atUnix: Double

    init(latch: Latch) {
        id = latch.id
        day = latch.day.rawValue
        chamber = latch.chamber.rawValue
        elapsed = latch.elapsed
        atUnix = latch.atUnix
    }

    func asLatch() throws -> Latch {
        guard let chamber = ChamberKind(rawValue: chamber) else { throw TaperCodec.Failure.corrupt }
        return Latch(
            id: id,
            day: WickDay(rawValue: day),
            chamber: chamber,
            elapsed: elapsed,
            atUnix: atUnix
        )
    }
}

private struct HollowDocument: Codable {
    var id: UUID
    var day: Int
    var chamber: String
    var atUnix: Double

    init(hollow: Hollow) {
        id = hollow.id
        day = hollow.day.rawValue
        chamber = hollow.chamber.rawValue
        atUnix = hollow.atUnix
    }

    func asHollow() throws -> Hollow {
        guard let chamber = ChamberKind(rawValue: chamber) else { throw TaperCodec.Failure.corrupt }
        return Hollow(
            id: id,
            day: WickDay(rawValue: day),
            chamber: chamber,
            atUnix: atUnix
        )
    }
}

private struct NightMarkDocument: Codable {
    var id: UUID
    var day: Int
    var snuffedUnix: Double
    var latchCount: Int
    var hollowCount: Int
    var line: String?

    init(mark: NightMark) {
        id = mark.id
        day = mark.day.rawValue
        snuffedUnix = mark.snuffedUnix
        latchCount = mark.latchCount
        hollowCount = mark.hollowCount
        line = mark.line
    }

    func asMark() -> NightMark {
        NightMark(
            id: id,
            day: WickDay(rawValue: day),
            snuffedUnix: snuffedUnix,
            latchCount: latchCount,
            hollowCount: hollowCount,
            line: line
        )
    }
}

private struct UnlitDocument: Codable {
    var id: UUID
    var day: Int
    var atUnix: Double

    init(miss: Unlit) {
        id = miss.id
        day = miss.day.rawValue
        atUnix = miss.atUnix
    }

    func asUnlit() -> Unlit {
        Unlit(id: id, day: WickDay(rawValue: day), atUnix: atUnix)
    }
}
