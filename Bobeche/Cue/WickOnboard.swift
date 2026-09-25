import SwiftUI

/// Role: Cue. One-shot cover. Three pages. Skip writes defaults. Re-runnable from Settings.
struct WickOnboard: View {
    @Bindable var watch: WickWatch
    @State private var page = 0

    var body: some View {
        VStack(spacing: WickFace.space(2)) {
            ScrollView {
                VStack(alignment: .leading, spacing: WickFace.space(2)) {
                    if WickArt.present(art) {
                        Image(art)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: WickFace.space(36))
                            .accessibilityHidden(true)
                    }
                    Text(title)
                        .font(WickFace.font(.display))
                        .foregroundStyle(WickInk.Palette.ink)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(line)
                        .font(WickFace.font(.body))
                        .foregroundStyle(WickInk.Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            WickVerbButton(
                title: page == 2 ? "Continue" : "Next",
                kind: .primary
            ) {
                if page == 2 {
                    Task { await watch.finishOnboarding() }
                } else {
                    page += 1
                }
            }
            WickVerbButton(
                title: "Skip",
                kind: .skip
            ) {
                Task { await watch.finishOnboarding() }
            }
        }
        .padding(WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WickInk.Palette.background.ignoresSafeArea())
        .interactiveDismissDisabled()
    }

    private var art: String {
        switch page {
        case 0: "boc_Onboarding1"
        case 1: "boc_Onboarding2"
        default: "boc_Onboarding3"
        }
    }

    private var title: String {
        switch page {
        case 0: "Walk tonight's taper"
        case 1: "Cue, Skip, Snuff"
        default: "File the night"
        }
    }

    private var line: String {
        switch page {
        case 0:
            "Light the wick. Reflect, then Breathe, then Ambient."
        case 1:
            "Cue latches a chamber when it is due. Skip writes a Hollow and walks on."
        default:
            "Snuff files a NightMark. History counts nights, not hours slept."
        }
    }
}
