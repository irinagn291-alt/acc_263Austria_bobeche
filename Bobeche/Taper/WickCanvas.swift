import SwiftUI

/// Role: Taper. Shared wick seats so chamber chrome sits on the glass taper, not in a side column.
enum WickWalk {
    static let wickRatio: CGFloat = 0.72
    static let labelRatio: CGFloat = 0.56
    static let flameTop: CGFloat = 0.10
    static let stemBottom: CGFloat = 0.84
    static let collarY: CGFloat = 0.78

    static func wickX(in size: CGSize) -> CGFloat {
        size.width * wickRatio
    }

    static func centers(height: CGFloat, tap: CGFloat = WickFace.tap) -> [CGFloat] {
        let count = ChamberKind.allCases.count
        let top = max(tap / 2, height * 0.20)
        let bottom = min(height - tap / 2, height * 0.70)
        guard count > 1 else { return [top] }
        let span = max(bottom - top, tap * CGFloat(count - 1))
        return (0..<count).map { index in
            top + span * CGFloat(index) / CGFloat(count - 1)
        }
    }
}

/// Role: Taper. One hero Canvas. Draws the glass taper and Ambient procedural glow. No bundled audio.
struct WickCanvas: View {
    var taper: Taper
    var elapsed: TimeInterval
    var date: Date
    var reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            drawDepth(context: &context, size: size)
            if showsGlow {
                drawGlow(context: &context, size: size)
            }
            drawCollar(context: &context, size: size)
            drawStem(context: &context, size: size)
            drawBeads(context: &context, size: size)
            if showsFlame {
                drawFlame(context: &context, size: size)
            }
        }
        .accessibilityHidden(true)
    }

    private var showsFlame: Bool {
        switch taper {
        case .lit, .ready:
            true
        default:
            false
        }
    }

    private var showsGlow: Bool {
        taper.openChamber == .ambient || readyAmbient
    }

    private var readyAmbient: Bool {
        if case .ready = taper { return true }
        return false
    }

    private func drawDepth(context: inout GraphicsContext, size: CGSize) {
        let field = Path(CGRect(origin: .zero, size: size))
        context.fill(field, with: .color(WickInk.Palette.surface.opacity(0.22)))
        context.fill(
            field,
            with: .radialGradient(
                Gradient(colors: [
                    WickInk.Palette.accent.opacity(0.16),
                    WickInk.Palette.surface.opacity(0.45),
                    Color.clear,
                ]),
                center: CGPoint(x: WickWalk.wickX(in: size), y: size.height * WickWalk.flameTop),
                startRadius: 4,
                endRadius: max(size.width, size.height) * 0.82
            )
        )
    }

    private func drawStem(context: inout GraphicsContext, size: CGSize) {
        let wickX = WickWalk.wickX(in: size)
        let top = size.height * WickWalk.flameTop
        let bottom = size.height * WickWalk.stemBottom
        let stemW = max(12, min(size.width * 0.055, size.height * 0.05))
        var stem = Path()
        stem.addRoundedRect(
            in: CGRect(x: wickX - stemW / 2, y: top, width: stemW, height: bottom - top),
            cornerSize: CGSize(width: stemW / 2, height: stemW / 2)
        )
        context.fill(
            stem,
            with: .linearGradient(
                Gradient(colors: [
                    WickInk.Palette.ink.opacity(0.22),
                    WickInk.Palette.muted.opacity(0.35),
                    WickInk.Palette.surface.opacity(0.9),
                ]),
                startPoint: CGPoint(x: wickX - stemW, y: top),
                endPoint: CGPoint(x: wickX + stemW, y: bottom)
            )
        )
        var core = Path()
        let coreW = stemW * 0.28
        core.addRoundedRect(
            in: CGRect(x: wickX - coreW / 2, y: top + 6, width: coreW, height: bottom - top - 18),
            cornerSize: CGSize(width: coreW / 2, height: coreW / 2)
        )
        context.fill(core, with: .color(WickInk.Palette.ink.opacity(0.18)))
    }

    private func drawCollar(context: inout GraphicsContext, size: CGSize) {
        let wickX = WickWalk.wickX(in: size)
        let y = size.height * WickWalk.collarY
        let width = min(size.width * 0.32, max(WickFace.space(14), size.height * 0.22))
        let height = max(WickFace.space(4), size.height * 0.08)
        var dish = Path()
        dish.addEllipse(in: CGRect(x: wickX - width / 2, y: y - height / 2, width: width, height: height))
        context.fill(dish, with: .color(WickInk.Palette.ink.opacity(0.08)))
        context.stroke(
            dish,
            with: .color(WickInk.Palette.ink.opacity(0.28)),
            lineWidth: 1.5
        )
        var lip = Path()
        let lipW = width * 0.62
        let lipH = height * 0.38
        lip.addEllipse(in: CGRect(x: wickX - lipW / 2, y: y - lipH / 2, width: lipW, height: lipH))
        context.stroke(lip, with: .color(WickInk.Palette.accent.opacity(0.35)), lineWidth: 1)
    }

    private func drawBeads(context: inout GraphicsContext, size: CGSize) {
        let wickX = WickWalk.wickX(in: size)
        let seats = WickWalk.centers(height: size.height)
        let scale = min(size.width, size.height)
        for (index, kind) in ChamberKind.allCases.enumerated() {
            let y = seats[index]
            let open = taper.openChamber == kind
            let sealed = taper.walkSeals.contains { $0.chamber == kind }
            let radius: CGFloat = open
                ? max(11, min(18, scale * 0.028))
                : max(7, min(13, scale * 0.018))
            let rect = CGRect(x: wickX - radius, y: y - radius, width: radius * 2, height: radius * 2)
            let bead = Path(ellipseIn: rect)
            let fill: Color
            if open {
                fill = WickInk.Palette.accent.opacity(0.85)
            } else if sealed {
                let latch = taper.walkSeals.first { $0.chamber == kind }?.isLatch == true
                fill = latch ? WickInk.Palette.ink.opacity(0.55) : WickInk.Palette.muted.opacity(0.45)
            } else {
                fill = WickInk.Palette.muted.opacity(0.28)
            }
            context.fill(bead, with: .color(fill))
        }
    }

    private func drawFlame(context: inout GraphicsContext, size: CGSize) {
        let wickX = WickWalk.wickX(in: size)
        let top = size.height * WickWalk.flameTop
        let ready: Bool
        if case .ready = taper { ready = true } else { ready = false }
        let height: CGFloat = max(ready ? 22 : 28, size.height * (ready ? 0.05 : 0.07))
        let half = max(9, height * 0.4)
        var flame = Path()
        flame.move(to: CGPoint(x: wickX, y: top - height))
        flame.addQuadCurve(
            to: CGPoint(x: wickX + half, y: top + 2),
            control: CGPoint(x: wickX + half * 1.5, y: top - height * 0.45)
        )
        flame.addQuadCurve(
            to: CGPoint(x: wickX - half, y: top + 2),
            control: CGPoint(x: wickX, y: top + 10)
        )
        flame.addQuadCurve(
            to: CGPoint(x: wickX, y: top - height),
            control: CGPoint(x: wickX - half * 1.5, y: top - height * 0.45)
        )
        context.fill(flame, with: .color(WickInk.Palette.accent.opacity(ready ? 0.55 : 0.9)))
    }

    private func drawGlow(context: inout GraphicsContext, size: CGSize) {
        let wickX = WickWalk.wickX(in: size)
        let y = size.height * 0.58
        let wave: Double
        if reduceMotion {
            wave = 0.42
        } else {
            wave = 0.28 + 0.22 * (sin(date.timeIntervalSince1970 * 1.35) + 1) / 2
        }
        let radius = max(size.width, size.height) * (0.18 + 0.08 * wave)
        let progress: Double
        if let open = taper.openChamber, open == .ambient, open.duration > 0 {
            progress = min(1, elapsed / open.duration)
        } else {
            progress = 1
        }
        context.fill(
            Path(ellipseIn: CGRect(x: wickX - radius, y: y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    WickInk.Palette.accent.opacity(0.22 + 0.2 * wave * progress),
                    WickInk.Palette.accent.opacity(0.05),
                    Color.clear,
                ]),
                center: CGPoint(x: wickX, y: y),
                startRadius: 4,
                endRadius: radius
            )
        )
    }
}
