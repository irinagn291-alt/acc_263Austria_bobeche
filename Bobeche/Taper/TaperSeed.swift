import Foundation

/// Role: Taper. Simulator demo ledger behind boc.demo.v1. Device never writes this.
enum TaperSeed {
    static let demoKey = TaperKey.demo

    static func ledger(now: Date = Date(), calendar: Calendar = .current) -> TaperLedger {
        let today = WickDay.from(now, calendar: calendar)
        let unix = now.timeIntervalSince1970
        let day1 = shifted(now, by: -4, calendar: calendar)
        let day2 = shifted(now, by: -3, calendar: calendar)
        let day3 = shifted(now, by: -2, calendar: calendar)
        let day4 = shifted(now, by: -1, calendar: calendar)

        let night1 = sealedNight(
            day: day1,
            unix: unix - 345_600,
            latches: [.reflect, .breathe, .ambient],
            hollows: [],
            line: "Still pond.",
            markID: fixed("11111111-1111-1111-1111-111111111111")
        )
        let night2 = sealedNight(
            day: day2,
            unix: unix - 259_200,
            latches: [.reflect, .ambient],
            hollows: [.breathe],
            line: nil,
            markID: fixed("22222222-2222-2222-2222-222222222222")
        )
        let night3 = sealedNight(
            day: day3,
            unix: unix - 172_800,
            latches: [.reflect, .breathe],
            hollows: [.ambient],
            line: "Low wick.",
            markID: fixed("33333333-3333-3333-3333-333333333333")
        )
        let night4 = sealedNight(
            day: day4,
            unix: unix - 86_400,
            latches: [.reflect, .breathe, .ambient],
            hollows: [],
            line: "Filed.",
            markID: fixed("44444444-4444-4444-4444-444444444444")
        )

        let tonightFlame = Flame(
            id: fixed("55555555-AAAA-0000-0000-000000000001"),
            day: today,
            litUnix: unix - 2_400
        )
        let tonightReflect = Latch(
            id: fixed("55555555-0000-0000-0000-000000000001"),
            day: today,
            chamber: .reflect,
            elapsed: ChamberKind.reflectSeconds,
            atUnix: unix - 2_310
        )
        let tonightBreathe = Hollow(
            id: fixed("55555555-0000-0000-0000-000000000002"),
            day: today,
            chamber: .breathe,
            atUnix: unix - 2_180
        )
        let tonightAmbient = Latch(
            id: fixed("55555555-0000-0000-0000-000000000003"),
            day: today,
            chamber: .ambient,
            elapsed: ChamberKind.ambientSeconds,
            atUnix: unix - 2_090
        )
        let tonightWalk = ChamberWalk(
            flame: tonightFlame,
            open: nil,
            openedUnix: nil,
            seals: [
                .latch(tonightReflect),
                .hollow(tonightBreathe),
                .latch(tonightAmbient),
            ],
            line: "Ready to snuff."
        )

        var latches = night1.latches + night2.latches + night3.latches + night4.latches
        latches.append(contentsOf: [tonightReflect, tonightAmbient])
        var hollows = night1.hollows + night2.hollows + night3.hollows + night4.hollows
        hollows.append(tonightBreathe)

        return TaperLedger(
            schemaVersion: TaperCodec.currentSchema,
            onboardingComplete: true,
            taper: .ready(tonightWalk),
            latches: latches,
            hollows: hollows,
            nightMarks: [night1.mark, night2.mark, night3.mark, night4.mark],
            unlits: []
        )
    }

    private static func shifted(_ now: Date, by days: Int, calendar: Calendar) -> WickDay {
        let start = calendar.startOfDay(for: now)
        let date = calendar.date(byAdding: .day, value: days, to: start) ?? start
        return WickDay.from(date, calendar: calendar)
    }

    private static func fixed(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }

    private static func sealedNight(
        day: WickDay,
        unix: Double,
        latches latchKinds: [ChamberKind],
        hollows hollowKinds: [ChamberKind],
        line: String?,
        markID: UUID
    ) -> (mark: NightMark, latches: [Latch], hollows: [Hollow]) {
        var latches: [Latch] = []
        var hollows: [Hollow] = []
        for (index, kind) in ChamberKind.allCases.enumerated() {
            let at = unix + Double(index) * 200
            if latchKinds.contains(kind) {
                latches.append(
                    Latch(
                        id: fixed("\(markID.uuidString.prefix(8))-0000-0000-0000-\(pad(index + 1))"),
                        day: day,
                        chamber: kind,
                        elapsed: kind.duration,
                        atUnix: at
                    )
                )
            } else if hollowKinds.contains(kind) {
                hollows.append(
                    Hollow(
                        id: fixed("\(markID.uuidString.prefix(8))-1111-0000-0000-\(pad(index + 1))"),
                        day: day,
                        chamber: kind,
                        atUnix: at
                    )
                )
            }
        }
        let mark = NightMark(
            id: markID,
            day: day,
            snuffedUnix: unix + 800,
            latchCount: latches.count,
            hollowCount: hollows.count,
            line: line
        )
        return (mark, latches, hollows)
    }

    private static func pad(_ value: Int) -> String {
        String(format: "%012d", value)
    }
}
