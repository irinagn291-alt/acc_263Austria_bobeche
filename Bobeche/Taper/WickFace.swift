import SwiftUI

/// Role: Taper. SF Pro type scale, 8pt spacing, 18/12 radii. Hex stays in WickInk.
enum WickFace {
    static let unit: CGFloat = 8
    static let tap: CGFloat = 44
    static let cardRadius: CGFloat = 18
    static let chipRadius: CGFloat = 12
    static let motion = Animation.easeOut(duration: 0.16)
    static let fade = Animation.easeOut(duration: 0.16)
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let glass: Material = .thinMaterial
    static let sheetGlass: Material = .regularMaterial

    static func space(_ steps: Int) -> CGFloat {
        unit * CGFloat(steps)
    }

    enum Step: CaseIterable {
        case display
        case glass
        case title
        case body
        case caption
        case figure

        var font: Font {
            switch self {
            case .display:
                .system(.largeTitle, design: .default).weight(.ultraLight)
            case .glass:
                .system(.title, design: .default).weight(.light)
            case .title:
                .system(.title3, design: .default).weight(.light)
            case .body:
                .system(.body, design: .default).weight(.regular)
            case .caption:
                .system(.footnote, design: .default).weight(.regular)
            case .figure:
                .system(.body, design: .default).weight(.regular).monospacedDigit()
            }
        }
    }

    static func font(_ step: Step) -> Font {
        step.font
    }

    static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
    }

    static var chipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: chipRadius, style: .continuous)
    }
}
