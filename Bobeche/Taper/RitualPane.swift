import SwiftUI

/// Role: Taper. Ritual home. Tonight's glass taper fills remaining height. Light, Cue, Skip, Snuff sit on the card.
struct RitualPane: View {
    @Bindable var watch: WickWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch watch.ritualLoad {
            case .fault:
                WickVacancy(
                    image: "boc_EmptyHome",
                    headline: "Tonight's taper could not be read",
                    line: watch.fault ?? "The last copy failed. Try again.",
                    actionTitle: "Retry",
                    loading: watch.isHauling
                ) {
                    Task { await watch.retry() }
                }
            case .empty:
                WickVacancy(
                    image: "boc_EmptyHome",
                    headline: "Build tonight's rite",
                    line: "Skip a block if you must.",
                    actionTitle: "Light the taper",
                    enabled: watch.canLight && !watch.isCommitting,
                    loading: watch.isCommitting
                ) {
                    Task { await watch.lightTaper() }
                }
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WickInk.Palette.background)
    }

    private var populated: some View {
        TimelineView(.animation(minimumInterval: tick, paused: paused)) { timeline in
            let elapsed = watch.elapsed(at: timeline.date)
            let remaining = watch.remaining(at: timeline.date)
            VStack(alignment: .leading, spacing: WickFace.space(2)) {
                if let fault = watch.fault {
                    WickBanner(text: fault) {
                        Task { await watch.retry() }
                    }
                } else if let notice = watch.notice {
                    WickBanner(text: notice, retryTitle: "OK") {
                        watch.notice = nil
                    }
                }
                glassCard(elapsed: elapsed, remaining: remaining, date: timeline.date)
                nightRail
            }
            .padding(.horizontal, WickFace.space(2))
            .padding(.top, WickFace.space(1))
            .padding(.bottom, WickFace.space(2))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func glassCard(elapsed: TimeInterval, remaining: TimeInterval, date: Date) -> some View {
        VStack(alignment: .leading, spacing: WickFace.space(2)) {
            header
            WickWalkStage(
                watch: watch,
                elapsed: elapsed,
                remaining: remaining,
                date: date,
                reduceMotion: reduceMotion
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contextMenu { taperMenu }
            controls(elapsed: elapsed, remaining: remaining)
        }
        .padding(WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                if WickArt.present("boc_CardBackdrop") {
                    Image("boc_CardBackdrop")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.35)
                        .accessibilityHidden(true)
                }
                Rectangle().fill(WickFace.glass)
            }
        }
        .clipShape(WickFace.cardShape)
        .overlay {
            WickFace.cardShape.stroke(WickInk.Palette.ink.opacity(0.12), lineWidth: WickPlate.hairline)
        }
        .contextMenu { taperMenu }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WickFace.space(1)) {
            HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
                Text(watch.jobTitle)
                    .font(WickFace.font(.display))
                    .foregroundStyle(WickInk.Palette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if WickArt.present("boc_HeaderDecor") {
                    Image("boc_HeaderDecor")
                        .resizable()
                        .scaledToFit()
                        .frame(width: WickFace.space(12), height: WickFace.space(6))
                        .accessibilityHidden(true)
                }
            }
            Text(watch.jobLine)
                .font(WickFace.font(.body))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                watch.showTwist = true
            } label: {
                Text("Cue then Snuff")
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.ink)
                    .padding(.horizontal, WickFace.space(2))
                    .frame(minHeight: WickFace.tap)
                    .background(WickInk.Palette.accent.opacity(0.18), in: WickFace.chipShape)
                    .overlay {
                        WickFace.chipShape.stroke(
                            WickInk.Palette.accent.opacity(0.45),
                            lineWidth: WickPlate.hairline
                        )
                    }
                    .contentShape(WickFace.chipShape)
            }
            .buttonStyle(WickPressStyle(enabled: true))
            .accessibilityLabel("Cue then Snuff")
            .accessibilityHint("How Cue, Skip, and Snuff file a night")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func controls(elapsed: TimeInterval, remaining: TimeInterval) -> some View {
        let cueReady = watch.canCue(elapsed: elapsed)
        return VStack(spacing: WickFace.space(1)) {
            WickVerbButton(
                title: "Snuff",
                detail: watch.canSnuff ? snuffDetail : "Walk first",
                kind: watch.liveVerb == .snuff ? .primary : .quiet,
                enabled: watch.canSnuff && !watch.isCommitting,
                loading: watch.isCommitting && watch.liveVerb == .snuff,
                hint: "Files a NightMark when Ready, or Unlit when Dark",
                art: watch.liveVerb == .snuff ? "boc_ControlFace" : nil
            ) {
                Task { await watch.snuffTaper() }
            }
            HStack(spacing: WickFace.space(1)) {
                WickVerbButton(
                    title: "Light",
                    kind: watch.liveVerb == .light ? .primary : .quiet,
                    enabled: watch.canLight && !watch.isCommitting,
                    loading: watch.isCommitting && watch.liveVerb == .light,
                    art: watch.liveVerb == .light ? "boc_ControlFace" : nil
                ) {
                    Task { await watch.lightTaper() }
                }
                WickVerbButton(
                    title: "Cue",
                    detail: cueReady ? "Due" : "\(WickFigures.seconds(remaining)) s",
                    kind: watch.liveVerb == .cue && cueReady ? .primary : .quiet,
                    enabled: cueReady && !watch.isCommitting,
                    loading: watch.isCommitting && watch.liveVerb == .cue,
                    art: watch.liveVerb == .cue && cueReady ? "boc_ControlFace" : nil
                ) {
                    Task { await watch.cueAtElapsed(elapsed) }
                }
            }
            WickVerbButton(
                title: "Skip",
                detail: "Writes a Hollow",
                kind: .skip,
                enabled: watch.canSkip && !watch.isCommitting,
                loading: watch.isCommitting && watch.canSkip
            ) {
                Task { await watch.skipChamber() }
            }
        }
    }

    private var nightRail: some View {
        VStack(spacing: WickFace.space(1)) {
            Button(action: watch.jumpHistory) {
                HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(WickFigures.integer(watch.streak))
                            .font(WickFace.font(.display).monospacedDigit())
                            .foregroundStyle(WickInk.Palette.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("Streak")
                            .font(WickFace.font(.caption))
                            .foregroundStyle(WickInk.Palette.muted)
                    }
                    Spacer(minLength: WickFace.space(1))
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(WickFigures.integer(watch.ledger.nightMarkCount))
                            .font(WickFace.font(.figure))
                            .foregroundStyle(WickInk.Palette.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("NightMarks")
                            .font(WickFace.font(.caption))
                            .foregroundStyle(WickInk.Palette.muted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .padding(.horizontal, WickFace.space(2))
                .padding(.vertical, WickFace.space(1))
                .frame(maxWidth: .infinity, minHeight: WickFace.tap, alignment: .leading)
                .wickOpaqueCard()
                .contentShape(WickFace.cardShape)
            }
            .buttonStyle(WickPressStyle(enabled: true))
            .accessibilityLabel(
                "Streak \(WickFigures.integer(watch.streak)). NightMarks \(WickFigures.integer(watch.ledger.nightMarkCount)). Open History."
            )

            ForEach(recentMarks) { row in
                Button(action: watch.jumpHistory) {
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
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(WickFigures.day(row.day, calendar: .current))
                            .font(WickFace.font(.caption))
                            .foregroundStyle(WickInk.Palette.muted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, WickFace.space(2))
                    .padding(.vertical, WickFace.space(1))
                    .frame(maxWidth: .infinity, minHeight: WickFace.tap, alignment: .leading)
                    .wickOpaqueCard()
                    .contentShape(WickFace.cardShape)
                }
                .buttonStyle(WickPressStyle(enabled: true))
                .accessibilityLabel("\(row.title). \(row.line). Open History.")
            }
        }
    }

    private var recentMarks: [WickFiling] {
        Array(
            WickFilingFold.make(from: watch.ledger)
                .filter { $0.kind == .mark }
                .prefix(2)
        )
    }

    @ViewBuilder
    private var taperMenu: some View {
        Text(watch.jobTitle)
        if watch.canWriteLine {
            Button("Write Line") { watch.openLine() }
        }
        Button("Cue then Snuff") { watch.showTwist = true }
        Button("Jump History") { watch.jumpHistory() }
    }

    private var snuffDetail: String {
        switch watch.ledger.taper {
        case .dark:
            "Writes Unlit"
        case .ready:
            "Files tonight"
        default:
            "Wait"
        }
    }

    private var tick: TimeInterval {
        if reduceMotion { return 1 }
        if watch.openChamber == .ambient { return 1.0 / 24.0 }
        return 1
    }

    private var paused: Bool {
        if case .lit = watch.ledger.taper { return false }
        return true
    }
}
