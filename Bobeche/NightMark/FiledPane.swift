import SwiftUI

/// Role: NightMark. History filings. Identity is the seal or mark UUID, never a row index.
struct WickFiling: Identifiable, Equatable {
    enum Kind: Equatable {
        case mark
        case latch
        case hollow
        case miss
    }

    var id: UUID
    var kind: Kind
    var day: WickDay
    var unix: Double
    var title: String
    var line: String
}

enum WickFilingFold {
    static func make(from ledger: TaperLedger) -> [WickFiling] {
        var rows: [WickFiling] = []
        rows.append(contentsOf: ledger.nightMarks.map { mark in
            WickFiling(
                id: mark.id,
                kind: .mark,
                day: mark.day,
                unix: mark.snuffedUnix,
                title: "NightMark",
                line: markLine(mark)
            )
        })
        rows.append(contentsOf: ledger.latches.map { latch in
            WickFiling(
                id: latch.id,
                kind: .latch,
                day: latch.day,
                unix: latch.atUnix,
                title: "Latch \(chamberTitle(latch.chamber))",
                line: "\(WickFigures.seconds(latch.elapsed)) s"
            )
        })
        rows.append(contentsOf: ledger.hollows.map { hollow in
            WickFiling(
                id: hollow.id,
                kind: .hollow,
                day: hollow.day,
                unix: hollow.atUnix,
                title: "Hollow \(chamberTitle(hollow.chamber))",
                line: "Skipped"
            )
        })
        rows.append(contentsOf: ledger.unlits.map { miss in
            WickFiling(
                id: miss.id,
                kind: .miss,
                day: miss.day,
                unix: miss.atUnix,
                title: "Unlit",
                line: "No streak"
            )
        })
        return rows.sorted { lhs, rhs in
            if lhs.unix == rhs.unix { return lhs.id.uuidString > rhs.id.uuidString }
            return lhs.unix > rhs.unix
        }
    }

    private static func markLine(_ mark: NightMark) -> String {
        let latches = WickFigures.integer(mark.latchCount)
        let hollows = WickFigures.integer(mark.hollowCount)
        if let line = mark.line, !line.isEmpty {
            return "\(latches) Latches, \(hollows) Hollows. \(line)"
        }
        return "\(latches) Latches, \(hollows) Hollows"
    }

    static func chamberTitle(_ kind: ChamberKind) -> String {
        switch kind {
        case .reflect: "Reflect"
        case .breathe: "Breathe"
        case .ambient: "Ambient"
        }
    }
}

/// Role: NightMark. History segment named for live shots. Counts NightMarks, Latches, Hollows, and the NightMark streak.
struct HistoryPane: View {
    @Bindable var watch: WickWatch

    var body: some View {
        FiledPane(watch: watch)
    }
}

/// Role: NightMark. History segment. Counts NightMarks, Latches, Hollows, and the NightMark streak.
struct FiledPane: View {
    @Bindable var watch: WickWatch
    private var calendar: Calendar { .current }

    var body: some View {
        Group {
            switch watch.historyLoad {
            case .fault:
                WickVacancy(
                    image: "boc_EmptyList",
                    headline: "History could not be read",
                    line: watch.fault ?? "The last copy failed. Try again.",
                    actionTitle: "Retry",
                    loading: watch.isHauling
                ) {
                    Task { await watch.retry() }
                }
            case .empty:
                WickVacancy(
                    image: "boc_EmptyList",
                    headline: "No nights filed",
                    line: "Snuff a Ready taper to write the first NightMark.",
                    actionTitle: "Open Ritual"
                ) {
                    watch.jumpRitual()
                }
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WickInk.Palette.background)
    }

    private var populated: some View {
        let rows = WickFilingFold.make(from: watch.ledger)
        return VStack(alignment: .leading, spacing: WickFace.space(2)) {
            streakHero
            ScrollView {
                LazyVStack(spacing: WickFace.space(1)) {
                    ForEach(rows) { row in
                        filingRow(row)
                    }
                }
                .padding(.bottom, WickFace.space(2))
            }
            .contentMargins(.bottom, WickFace.space(2))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.top, WickFace.space(1))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var streakHero: some View {
        VStack(alignment: .leading, spacing: WickFace.space(1)) {
            Text(WickFigures.integer(watch.streak))
                .font(WickFace.font(.display).monospacedDigit())
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Consecutive NightMark days")
                .font(WickFace.font(.body))
                .foregroundStyle(WickInk.Palette.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
                Text("NightMarks \(WickFigures.integer(watch.ledger.nightMarkCount))")
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: WickFace.space(1))
                Text("Latches \(WickFigures.integer(watch.ledger.latchCount)). Hollows \(WickFigures.integer(watch.ledger.hollowCount))")
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(WickFace.space(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .wickOpaqueCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Streak \(WickFigures.integer(watch.streak)) consecutive NightMark days. NightMarks \(WickFigures.integer(watch.ledger.nightMarkCount)). Latches \(WickFigures.integer(watch.ledger.latchCount)). Hollows \(WickFigures.integer(watch.ledger.hollowCount))"
        )
    }

    private func filingRow(_ row: WickFiling) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(row.title)
                    .font(WickFace.font(.body))
                    .foregroundStyle(WickInk.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(row.line)
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(WickFigures.day(row.day, calendar: calendar))
                .font(WickFace.font(.caption))
                .foregroundStyle(WickInk.Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.vertical, WickFace.space(1))
        .frame(maxWidth: .infinity, minHeight: WickFace.tap, alignment: .leading)
        .wickOpaqueCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title). \(row.line). \(WickFigures.day(row.day, calendar: calendar))")
    }
}
