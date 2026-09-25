import SwiftUI

/// Role: Taper. Settings segment. Contact, re-run onboarding, confirmed resetAllData. Opaque fill plus hairline.
struct WickSettings: View {
    @Bindable var watch: WickWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var confirmReset = false

    var body: some View {
        Group {
            switch watch.settingsLoad {
            case .fault:
                WickVacancy(
                    image: "boc_EmptyList",
                    headline: "Settings could not be read",
                    line: watch.fault ?? "The last copy failed. Try again.",
                    actionTitle: "Retry",
                    loading: watch.isHauling
                ) {
                    Task { await watch.retry() }
                }
            case .empty:
                empty
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WickInk.Palette.background)
        .confirmationDialog(
            "Erase all nights?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Erase all nights", role: .destructive) {
                Task { await watch.resetAll() }
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text("Latches, Hollows, and NightMarks leave this device.")
        }
    }

    private var empty: some View {
        VStack(spacing: WickFace.space(2)) {
            VStack(spacing: WickFace.space(2)) {
                if WickArt.present("boc_EmptyHome") {
                    Image("boc_EmptyHome")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: WickFace.space(28), maxHeight: WickFace.space(22))
                        .accessibilityHidden(true)
                }
                Text("No nights on this device")
                    .font(WickFace.font(.title))
                    .foregroundStyle(WickInk.Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                Text("Contact stays here. Light a taper from Ritual.")
                    .font(WickFace.font(.body))
                    .foregroundStyle(WickInk.Palette.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                contactCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            WickVerbButton(
                title: "Open Ritual",
                kind: .primary
            ) {
                watch.jumpRitual()
            }
            WickVerbButton(
                title: "Re-run onboarding",
                kind: .quiet,
                enabled: !watch.isCommitting
            ) {
                Task { await watch.reopenOnboarding() }
            }
            WickVerbButton(
                title: "Reset all data",
                detail: "Erase nights on this device",
                kind: .destroy,
                enabled: !watch.isCommitting
            ) {
                confirmReset = true
            }
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.bottom, WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populated: some View {
        VStack(spacing: WickFace.space(2)) {
            walkPlate
            contactCard
            WickVerbButton(
                title: "Cue then Snuff",
                detail: "How the walk files a night",
                kind: .quiet
            ) {
                watch.showTwist = true
            }
            WickVerbButton(
                title: "Re-run onboarding",
                kind: .quiet,
                enabled: !watch.isCommitting
            ) {
                Task { await watch.reopenOnboarding() }
            }
            WickVerbButton(
                title: "Reset all data",
                detail: "Erase nights on this device",
                kind: .destroy,
                enabled: !watch.isCommitting,
                loading: watch.isCommitting
            ) {
                confirmReset = true
            }
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.top, WickFace.space(1))
        .padding(.bottom, WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var walkPlate: some View {
        VStack(alignment: .leading, spacing: WickFace.space(2)) {
            Text(watch.jobTitle)
                .font(WickFace.font(.title))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Cue writes a Latch. Skip writes a Hollow. Snuff files a NightMark.")
                .font(WickFace.font(.body))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(4)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            WickWalkStage(
                watch: watch,
                elapsed: 0,
                remaining: 0,
                date: Date(),
                reduceMotion: reduceMotion
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: WickFace.space(28))
            readoutRow
        }
        .padding(WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .wickOpaqueCard()
    }

    private var readoutRow: some View {
        VStack(spacing: WickFace.space(1)) {
            HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
                figure("NightMarks", watch.ledger.nightMarkCount)
                figure("Latches", watch.ledger.latchCount)
            }
            HStack(alignment: .firstTextBaseline, spacing: WickFace.space(2)) {
                figure("Hollows", watch.ledger.hollowCount)
                figure("Streak", watch.streak)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "NightMarks \(WickFigures.integer(watch.ledger.nightMarkCount)). Latches \(WickFigures.integer(watch.ledger.latchCount)). Hollows \(WickFigures.integer(watch.ledger.hollowCount)). Streak \(WickFigures.integer(watch.streak))"
        )
    }

    private func figure(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(WickFigures.integer(value))
                .font(WickFace.font(.figure))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(WickFace.font(.caption))
                .foregroundStyle(WickInk.Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: WickFace.tap, alignment: .leading)
    }

    private var contactCard: some View {
        let contactURL = TaperClient.contactURL
        return Link(destination: contactURL) {
            HStack(alignment: .center, spacing: WickFace.space(2)) {
                Image(systemName: "envelope")
                    .font(WickFace.font(.body))
                    .foregroundStyle(WickInk.Palette.ink)
                    .frame(width: WickFace.tap, height: WickFace.tap)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: WickFace.space(1)) {
                    Text("Contact")
                        .font(WickFace.font(.body))
                        .foregroundStyle(WickInk.Palette.ink)
                    Text(contactURL.absoluteString)
                        .font(WickFace.font(.caption))
                        .foregroundStyle(WickInk.Palette.accent)
                        .underline()
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.trailing, WickFace.space(2))
            .frame(maxWidth: .infinity, minHeight: WickFace.tap, alignment: .leading)
            .wickOpaqueCard()
            .contentShape(WickFace.cardShape)
        }
        .buttonStyle(WickPressStyle(enabled: true))
        .accessibilityLabel("Contact")
        .accessibilityValue(contactURL.absoluteString)
    }
}
