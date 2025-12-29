import Foundation

/// 月份区块数据模型（用于日期选择器按月分段展示）
struct MonthSection: Identifiable, Equatable {
    let year: Int
    let month: Int             // 1...12
    let days: [Date]           // 该月所有日期（从1号到月末）
    let leadingBlankCount: Int // 第一天之前需要的空白占位数（对齐星期列）

    // ✅ 稳定 ID：同一年同一月永远相同，SwiftUI diff 才不会把整列表当新数据
    var id: String { "\(year)-\(month)" }

    /// 获取月份标题文本
    func getHeaderText() -> String {
        // 1月显示年份
        if month == 1 {
            return "\(month)月, \(year)"
        } else {
            return "\(month)月"
        }
    }

    // Equatable 实现（用于比较）
    static func == (lhs: MonthSection, rhs: MonthSection) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
}

/// 生成月份区块列表的辅助方法
extension MonthSection {
    /// 生成指定日期范围内的所有月份区块
    /// - Parameters:
    ///   - startDate: 起始日期
    ///   - endDate: 结束日期
    /// - Returns: 月份区块数组
    static func generateMonthSections(from startDate: Date, to endDate: Date) -> [MonthSection] {
        let calendar = Calendar.current
        var sections: [MonthSection] = []

        // 从起始日期所在月的1号开始
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) else {
            return []
        }

        var currentMonthStart = monthStart

        // 循环生成每个月的区块，直到超过结束日期
        while currentMonthStart <= endDate {
            let year = calendar.component(.year, from: currentMonthStart)
            let month = calendar.component(.month, from: currentMonthStart)

            // 计算该月有多少天
            guard let range = calendar.range(of: .day, in: .month, for: currentMonthStart) else {
                // 跳到下个月
                guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) else {
                    break
                }
                currentMonthStart = nextMonth
                continue
            }

            // 生成该月所有日期，并按 endDate 截断
            let daysInMonth = (1...range.count).compactMap { day -> Date? in
                var components = DateComponents()
                components.year = year
                components.month = month
                components.day = day
                guard let date = calendar.date(from: components) else { return nil }

                // ✅ 如果日期超过 endDate，不渲染
                if date > endDate {
                    return nil
                }

                return date
            }

            // ✅ 如果该月没有任何有效日期（所有日期都超过 endDate），跳过该月
            guard !daysInMonth.isEmpty else {
                // 移动到下个月
                guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) else {
                    break
                }
                currentMonthStart = nextMonth
                continue
            }

            // 计算该月1号是星期几（周一=1, 周日=7）
            let firstDayWeekday = calendar.component(.weekday, from: currentMonthStart)
            // 转换为前置空白数（周一=0, 周二=1, ..., 周日=6）
            let leadingBlanks = (firstDayWeekday == 1) ? 6 : (firstDayWeekday - 2)

            // 创建月份区块
            let section = MonthSection(
                year: year,
                month: month,
                days: daysInMonth,
                leadingBlankCount: leadingBlanks
            )
            sections.append(section)

            // 移动到下个月
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) else {
                break
            }
            currentMonthStart = nextMonth
        }

        return sections
    }
}
