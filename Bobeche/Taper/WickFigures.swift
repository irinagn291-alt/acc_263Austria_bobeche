import Foundation

/// Role: Taper. Display fold for integers, elapsed seconds, and WickDay. Round only here.
enum WickFigures {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func seconds(_ value: TimeInterval) -> String {
        let whole = max(0, Int(value.rounded(.towardZero)))
        return integer(whole)
    }

    static func day(_ value: WickDay, calendar: Calendar) -> String {
        guard let start = value.startDate(calendar: calendar) else {
            return integer(value.rawValue)
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: start)
    }
}
