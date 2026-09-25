import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Role: Taper. Named art only when the imageset holds a bitmap.
enum WickArt {
    static func present(_ name: String) -> Bool {
        #if canImport(UIKit)
        UIImage(named: name) != nil
        #else
        false
        #endif
    }
}

enum WickPlate {
    static let hairline: CGFloat = 1
}

/// Role: Taper. Pressed scale. Reduce Motion fades. Disabled is faded, not identical.
struct WickPressStyle: ButtonStyle {
    var enabled: Bool
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        WickPressBody(configuration: configuration, enabled: enabled, loading: loading)
    }
}

private struct WickPressBody: View {
    var configuration: ButtonStyle.Configuration
    var enabled: Bool
    var loading: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed && enabled && !loading ? WickFace.pressScale : 1)
            .opacity(enabled ? (configuration.isPressed ? 0.88 : 1) : 0.45)
            .animation(reduceMotion ? WickFace.fade : WickFace.motion, value: configuration.isPressed)
    }
}

enum WickFlameKind: Equatable {
    case primary
    case quiet
    case skip
    case destroy
}

/// Role: Taper. Native chrome. Primary is tinted glass. Skip is not destroy. Reset is destroy.
struct WickVerbButton: View {
    var title: String
    var detail: String? = nil
    var kind: WickFlameKind
    var fills: Bool = true
    var enabled: Bool = true
    var loading: Bool = false
    var hint: String? = nil
    var art: String? = nil
    var action: () -> Void

    private var active: Bool { enabled && !loading }

    var body: some View {
        Button(action: action) {
            HStack(spacing: WickFace.space(1)) {
                if loading {
                    ProgressView()
                        .tint(labelInk)
                        .frame(width: WickFace.space(2), height: WickFace.space(2))
                } else if let art, WickArt.present(art) {
                    Image(art)
                        .resizable()
                        .scaledToFit()
                        .frame(width: WickFace.space(4), height: WickFace.space(4))
                        .accessibilityHidden(true)
                }
                VStack(spacing: 0) {
                    Text(title)
                        .font(WickFace.font(.body))
                        .foregroundStyle(labelInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if let detail {
                        Text(detail)
                            .font(WickFace.font(.caption))
                            .foregroundStyle(labelInk.opacity(0.86))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: fills ? .infinity : nil)
            }
            .padding(.horizontal, WickFace.space(2))
            .frame(maxWidth: fills ? .infinity : nil, minHeight: WickFace.tap)
            .background { chrome }
            .clipShape(WickFace.cardShape)
            .overlay {
                WickFace.cardShape.stroke(strokePaint, lineWidth: WickPlate.hairline)
            }
            .contentShape(WickFace.cardShape)
        }
        .buttonStyle(WickPressStyle(enabled: active, loading: loading))
        .disabled(!active)
        .accessibilityLabel(detail.map { "\(title). \($0)" } ?? title)
        .accessibilityHint(hint ?? "")
    }

    @ViewBuilder
    private var chrome: some View {
        switch kind {
        case .primary:
            ZStack {
                WickFace.cardShape.fill(WickFace.glass)
                WickFace.cardShape.fill(WickInk.Palette.accent.opacity(active ? 0.28 : 0.12))
            }
        case .quiet, .skip, .destroy:
            WickFace.cardShape.fill(fillPaint)
        }
    }

    private var labelInk: Color {
        switch kind {
        case .primary:
            active ? WickInk.Palette.ink : WickInk.Palette.muted
        case .quiet, .skip, .destroy:
            active ? WickInk.Palette.ink : WickInk.Palette.muted
        }
    }

    private var fillPaint: Color {
        switch kind {
        case .primary:
            WickInk.Palette.accent.opacity(active ? 0.28 : 0.12)
        case .quiet, .skip:
            WickInk.Palette.surface.opacity(active ? 0.92 : 0.6)
        case .destroy:
            WickInk.Palette.muted.opacity(active ? 0.22 : 0.12)
        }
    }

    private var strokePaint: Color {
        switch kind {
        case .primary:
            WickInk.Palette.accent.opacity(active ? 0.7 : 0.25)
        case .quiet, .skip:
            WickInk.Palette.muted.opacity(0.45)
        case .destroy:
            WickInk.Palette.muted.opacity(0.55)
        }
    }
}

/// Role: Taper. Full-page empty or fault. Cutout art, one headline, one line, bottom full-width CTA.
struct WickVacancy: View {
    var image: String
    var headline: String
    var line: String
    var actionTitle: String
    var enabled: Bool = true
    var loading: Bool = false
    var action: () -> Void

    var body: some View {
        VStack(spacing: WickFace.space(2)) {
            VStack(spacing: WickFace.space(2)) {
                if WickArt.present(image) {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: WickFace.space(28), maxHeight: WickFace.space(28))
                        .accessibilityHidden(true)
                }
                Text(headline)
                    .font(WickFace.font(.title))
                    .foregroundStyle(WickInk.Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                Text(line)
                    .font(WickFace.font(.body))
                    .foregroundStyle(WickInk.Palette.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            WickVerbButton(
                title: actionTitle,
                kind: .primary,
                enabled: enabled,
                loading: loading,
                action: action
            )
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.bottom, WickFace.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WickInk.Palette.background)
    }
}

/// Role: Taper. Recoverable fault with Retry.
struct WickBanner: View {
    var text: String
    var retryTitle: String = "Retry"
    var retry: () -> Void

    var body: some View {
        HStack(spacing: WickFace.space(1)) {
            Text(text)
                .font(WickFace.font(.caption))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: retry) {
                Text(retryTitle)
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.ink)
                    .frame(minWidth: WickFace.tap, minHeight: WickFace.tap)
                    .padding(.horizontal, WickFace.space(1))
                    .background(WickInk.Palette.surface, in: WickFace.chipShape)
                    .overlay {
                        WickFace.chipShape.stroke(
                            WickInk.Palette.muted.opacity(0.45),
                            lineWidth: WickPlate.hairline
                        )
                    }
                    .contentShape(WickFace.chipShape)
            }
            .buttonStyle(WickPressStyle(enabled: true))
            .accessibilityLabel(retryTitle)
        }
        .padding(.horizontal, WickFace.space(2))
        .padding(.vertical, WickFace.space(1))
        .frame(maxWidth: .infinity, minHeight: WickFace.tap, alignment: .leading)
        .background(WickInk.Palette.surface, in: WickFace.cardShape)
        .overlay {
            WickFace.cardShape.stroke(WickInk.Palette.muted.opacity(0.45), lineWidth: WickPlate.hairline)
        }
    }
}

/// Role: Taper. Sheet header with a dismiss that always works.
struct WickSheetBar: View {
    var title: String
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: WickFace.space(1)) {
            Text(title)
                .font(WickFace.font(.title))
                .foregroundStyle(WickInk.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(WickFace.font(.body))
                    .foregroundStyle(WickInk.Palette.ink)
                    .frame(width: WickFace.tap, height: WickFace.tap)
                    .contentShape(Rectangle())
            }
            .buttonStyle(WickPressStyle(enabled: true))
            .accessibilityLabel("Close")
        }
        .frame(maxWidth: .infinity, minHeight: WickFace.tap)
    }
}

struct WickSheetRise: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion || appeared ? 1 : WickFace.sheetScale)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(reduceMotion ? WickFace.fade : WickFace.motion) {
                    appeared = true
                }
            }
    }
}

extension View {
    func wickOpaqueCard() -> some View {
        background(WickInk.Palette.surface, in: WickFace.cardShape)
            .overlay {
                WickFace.cardShape.stroke(WickInk.Palette.muted.opacity(0.45), lineWidth: WickPlate.hairline)
            }
    }

    func wickScreen() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WickInk.Palette.background.ignoresSafeArea())
    }

    func wickSheetRise() -> some View {
        modifier(WickSheetRise())
    }
}
