import Foundation

/// Role: NightMark. Snuff on Ready filed this night and froze the walk. Streak uses these days.
struct NightMark: Equatable, Sendable, Identifiable {
    var id: UUID
    var day: WickDay
    var snuffedUnix: Double
    var latchCount: Int
    var hollowCount: Int
    var line: String?
}

/// Role: NightMark. Snuff on Dark wrote Unlit. This day does not streak.
struct Unlit: Equatable, Sendable, Identifiable {
    var id: UUID
    var day: WickDay
    var atUnix: Double
}

/// Role: NightMark. Frozen night after Snuff. Ready freeze keeps the walk; Dark freeze is Unlit.
enum FiledNight: Equatable, Sendable {
    case nightMark(NightMark, ChamberWalk)
    case unlit(Unlit)

    var day: WickDay {
        switch self {
        case .nightMark(let mark, _): mark.day
        case .unlit(let miss): miss.day
        }
    }
}

/// Role: NightMark. Consecutive NightMark days from the newest filed night. Unlit yields zero.
enum WickStreak {
    static func current(marks: [NightMark], unlits: [Unlit], calendar: Calendar) -> Int {
        let markDays = Set(marks.map(\.day))
        let unlitDays = Set(unlits.map(\.day))
        let newest: WickDay?
        if let mark = markDays.max(), let miss = unlitDays.max() {
            newest = max(mark, miss)
        } else {
            newest = markDays.max() ?? unlitDays.max()
        }
        guard let start = newest else { return 0 }
        if unlitDays.contains(start), !markDays.contains(start) {
            return 0
        }
        var count = 0
        var cursor: WickDay? = start
        while let day = cursor, markDays.contains(day) {
            count += 1
            cursor = day.previous(calendar: calendar)
        }
        return count
    }
}
