import SwiftUI

/// Role: Chamber. One wick plus named chambers along it. The open chamber is larger. Not three equal cards.
struct WickWalkStage: View {
    var watch: WickWatch
    var elapsed: TimeInterval
    var remaining: TimeInterval
    var date: Date
    var reduceMotion: Bool

    var body: some View {
        ZStack {
            WickCanvas(
                taper: watch.ledger.taper,
                elapsed: elapsed,
                date: date,
                reduceMotion: reduceMotion
            )
            ChamberStem(watch: watch, remaining: remaining)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .accessibilityElement(children: .contain)
    }
}

/// Role: Chamber. Named chambers along one wick. The open chamber is larger. Not three equal cards.
struct ChamberStem: View {
    var watch: WickWatch
    var remaining: TimeInterval
    @ScaledMetric(relativeTo: .body) private var quietBead: CGFloat = WickFace.space(3)
    @ScaledMetric(relativeTo: .body) private var liveBead: CGFloat = WickFace.space(6)

    var body: some View {
        GeometryReader { geo in
            let tap = max(WickFace.tap, liveBead)
            let width = min(
                geo.size.width * WickWalk.labelRatio,
                max(WickFace.space(18), geo.size.width - WickFace.space(10))
            )
            let seats = WickWalk.centers(height: geo.size.height, tap: tap)
            ForEach(Array(ChamberKind.allCases.enumerated()), id: \.element) { index, kind in
                chamberRow(kind)
                    .frame(width: width, alignment: .leading)
                    .position(
                        x: WickFace.space(1) + width / 2,
                        y: seats[index]
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func chamberRow(_ kind: ChamberKind) -> some View {
        let open = watch.openChamber == kind
        let height = open ? liveBead : quietBead
        return Button {
            tap(kind)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(title(kind))
                    .font(open ? WickFace.font(.glass) : WickFace.font(.body))
                    .foregroundStyle(open ? WickInk.Palette.ink : WickInk.Palette.ink.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(status(kind))
                    .font(WickFace.font(.caption))
                    .foregroundStyle(WickInk.Palette.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, WickFace.space(2))
            .padding(.vertical, WickFace.space(1))
            .frame(maxWidth: .infinity, minHeight: max(height, WickFace.tap), alignment: .leading)
            .padding(.trailing, open ? 0 : WickFace.space(4))
            .background(chipFill(open: open, kind: kind), in: WickFace.chipShape)
            .overlay {
                WickFace.chipShape.stroke(chipStroke(open: open), lineWidth: WickPlate.hairline)
            }
            .contentShape(WickFace.chipShape)
        }
        .buttonStyle(WickPressStyle(enabled: true))
        .contextMenu {
            Text(status(kind))
            if kind == .reflect, watch.canWriteLine {
                Button("Write Line") { watch.openLine() }
            }
            Button("Jump History") { watch.jumpHistory() }
        }
        .accessibilityLabel("\(title(kind)). \(status(kind))")
    }

    private func chipFill(open: Bool, kind: ChamberKind) -> Color {
        if open {
            return WickInk.Palette.accent.opacity(0.22)
        }
        if let seal = watch.seal(for: kind), seal.isLatch {
            return WickInk.Palette.surface.opacity(0.92)
        }
        return WickInk.Palette.surface.opacity(0.72)
    }

    private func chipStroke(open: Bool) -> Color {
        open ? WickInk.Palette.accent.opacity(0.55) : WickInk.Palette.ink.opacity(0.14)
    }

    private func tap(_ kind: ChamberKind) {
        if kind == .reflect, watch.canWriteLine {
            watch.openLine()
        } else if watch.seal(for: kind) != nil {
            watch.jumpHistory()
        } else {
            watch.showTwist = true
        }
    }

    private func title(_ kind: ChamberKind) -> String {
        switch kind {
        case .reflect: "Reflect"
        case .breathe: "Breathe"
        case .ambient: "Ambient"
        }
    }

    private func status(_ kind: ChamberKind) -> String {
        if watch.openChamber == kind {
            let due = WickFigures.seconds(remaining)
            return "Open. \(due) s left"
        }
        if let seal = watch.seal(for: kind) {
            switch seal {
            case .latch(let latch):
                return "Latch. \(WickFigures.seconds(latch.elapsed)) s"
            case .hollow:
                return "Hollow"
            }
        }
        return "Wait"
    }
}
