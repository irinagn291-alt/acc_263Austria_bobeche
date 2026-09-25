import SwiftUI

/// Role: Cue. Twist screen for Cue-then-snuff. Own surface plus the Ritual verbs.
struct CueSnuffPane: View {
    @Bindable var watch: WickWatch

    var body: some View {
        VStack(alignment: .leading, spacing: WickFace.space(2)) {
            WickSheetBar(title: "Cue then Snuff") {
                watch.showTwist = false
            }
            Group {
                switch watch.twistLoad {
                case .fault:
                    WickVacancy(
                        image: "boc_TwistHero",
                        headline: "The walk could not be read",
                        line: watch.fault ?? "The last copy failed. Try again.",
                        actionTitle: "Retry"
                    ) {
                        Task { await watch.retry() }
                    }
                case .empty:
                    WickVacancy(
                        image: "boc_TwistHero",
                        headline: "Cue latches. Skip hollows.",
                        line: "Snuff files the night. Light tonight's taper to begin.",
                        actionTitle: "Open Ritual"
                    ) {
                        watch.jumpRitual()
                    }
                case .populated:
                    populated
                }
            }
        }
        .padding(WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle().fill(WickFace.sheetGlass)
                .ignoresSafeArea()
        }
        .wickSheetRise()
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: WickFace.space(2)) {
            if WickArt.present("boc_TwistHero") {
                Image("boc_TwistHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: WickFace.space(22))
                    .accessibilityHidden(true)
            }
            Text(WickFigures.integer(watch.ledger.latchCount))
                .font(WickFace.font(.display).monospacedDigit())
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Latches on this device")
                .font(WickFace.font(.title))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .truncationMode(.tail)
            Text("Cue latches a chamber and opens the next. Skip writes a Hollow. Snuff files the night.")
                .font(WickFace.font(.body))
                .foregroundStyle(WickInk.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(
                "Hollows \(WickFigures.integer(watch.ledger.hollowCount)). NightMarks \(WickFigures.integer(watch.ledger.nightMarkCount))."
            )
            .font(WickFace.font(.caption))
            .foregroundStyle(WickInk.Palette.muted)
            .fixedSize(horizontal: false, vertical: true)
            Text(watch.jobLine)
                .font(WickFace.font(.caption))
                .foregroundStyle(WickInk.Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: WickFace.space(2))
            WickVerbButton(
                title: "Open Ritual",
                kind: .primary
            ) {
                watch.jumpRitual()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
