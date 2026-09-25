import Foundation

/// Role: Taper. Night key as Int YYYYMMDD from Calendar.startOfDay. Never a Date dictionary key.
struct WickDay: RawRepresentable, Hashable, Sendable, Comparable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static func from(_ date: Date, calendar: Calendar) -> WickDay {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 1970
        let month = parts.month ?? 1
        let day = parts.day ?? 1
        return WickDay(rawValue: year * 10_000 + month * 100 + day)
    }

    func startDate(calendar: Calendar) -> Date? {
        var parts = DateComponents()
        parts.year = rawValue / 10_000
        parts.month = (rawValue / 100) % 100
        parts.day = rawValue % 100
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }

    func previous(calendar: Calendar) -> WickDay? {
        guard let start = startDate(calendar: calendar),
              let prior = calendar.date(byAdding: .day, value: -1, to: start)
        else {
            return nil
        }
        return WickDay.from(prior, calendar: calendar)
    }

    static func < (lhs: WickDay, rhs: WickDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
