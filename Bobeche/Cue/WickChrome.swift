import SwiftUI

/// Role: Cue. One root. Ritual, History, and Settings switch in place. No TabView. The taper never pops.
struct WickChrome: View {
    @Bindable var watch: WickWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if !watch.didLoad {
                loading
            } else {
                shell
            }
        }
        .tint(WickInk.Palette.accent)
        .background(WickInk.Palette.background.ignoresSafeArea())
        .fullScreenCover(isPresented: onboardingBind) {
            WickOnboard(watch: watch)
        }
        .sheet(isPresented: $watch.showLine) {
            WickLineSheet(watch: watch)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(WickFace.sheetGlass)
        }
        .sheet(isPresented: $watch.showTwist) {
            CueSnuffPane(watch: watch)
                .presentationDragIndicator(.visible)
                .presentationBackground(WickFace.sheetGlass)
        }
        .sensoryFeedback(.success, trigger: watch.snuffTick)
        .overlay(alignment: .top) {
            if watch.showSuccess, WickArt.present("boc_SuccessMark") {
                Image("boc_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: WickFace.space(8), height: WickFace.space(8))
                    .padding(.top, WickFace.space(2))
                    .opacity(0.95)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
    }

    private var loading: some View {
        ZStack {
            depthField
            if watch.isHauling {
                ProgressView()
                    .tint(WickInk.Palette.accent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shell: some View {
        VStack(spacing: WickFace.space(1)) {
            picker
            pane
                .animation(reduceMotion ? WickFace.fade : WickFace.motion, value: watch.segment)
        }
        .background(depthField)
    }

    private var picker: some View {
        Picker("Taper", selection: $watch.segment) {
            Text("Ritual").tag(WickSegment.ritual)
            Text("History").tag(WickSegment.history)
            Text("Settings").tag(WickSegment.settings)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, WickFace.space(2))
        .padding(.top, WickFace.space(1))
        .accessibilityLabel("Taper")
    }

    @ViewBuilder
    private var pane: some View {
        switch watch.segment {
        case .ritual:
            RitualPane(watch: watch)
        case .history:
            HistoryPane(watch: watch)
        case .settings:
            WickSettings(watch: watch)
        }
    }

    private var depthField: some View {
        ZStack {
            WickInk.Palette.background
            RadialGradient(
                colors: [
                    WickInk.Palette.surface.opacity(0.95),
                    WickInk.Palette.background,
                ],
                center: .top,
                startRadius: WickFace.space(2),
                endRadius: WickFace.space(48)
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var onboardingBind: Binding<Bool> {
        Binding(
            get: { watch.showsOnboarding },
            set: { presented in
                if !presented {
                    Task { await watch.finishOnboarding() }
                }
            }
        )
    }
}
