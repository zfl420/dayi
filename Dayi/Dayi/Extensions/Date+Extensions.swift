import Foundation

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func daysSince(_ other: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: other.startOfDay(), to: self.startOfDay())
        return components.day ?? 0
    }

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var monthDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    func getWeekStart() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 2 // 周一为一周的开始

        // 获取当前日期所在周的周一
        let weekday = calendar.component(.weekday, from: self)
        // weekday: 1=周日, 2=周一, ..., 7=周六
        // 计算到周一需要减去的天数
        let daysToSubtract = (weekday == 1) ? 6 : (weekday - 2)
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self.startOfDay()) ?? self
    }
}
