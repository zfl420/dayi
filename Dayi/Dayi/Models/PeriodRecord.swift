import Foundation

/// 旧版月经记录模型（用于数据迁移）
struct LegacyPeriodRecord: Codable {
    let startDate: Date

    /// 转换为新格式
    func toNewFormat() -> PeriodRecord {
        return PeriodRecord(startDate: startDate, duration: 6)
    }
}

/// 月经记录模型（重构版 - 支持多日期存储）
struct PeriodRecord: Codable, Equatable, Identifiable {
    /// 唯一标识符
    let id: UUID

    /// 经期包含的所有日期（存储为 TimeInterval 便于 Codable）
    private var dateIntervals: [TimeInterval]

    /// 经期包含的所有日期（计算属性，已排序）
    var dates: [Date] {
        get {
            dateIntervals.map { Date(timeIntervalSince1970: $0) }.sorted()
        }
        set {
            dateIntervals = newValue.map { $0.startOfDay().timeIntervalSince1970 }.sorted()
        }
    }

    /// 经期开始日（第一个日期）
    var startDate: Date? {
        dates.first
    }

    /// 经期结束日（最后一个日期）
    var endDate: Date? {
        dates.last
    }

    /// 经期天数
    var duration: Int {
        dates.count
    }

    /// 判断是否包含某个日期
    func contains(_ date: Date) -> Bool {
        let targetDay = date.startOfDay()
        return dates.contains { $0.isSameDay(as: targetDay) }
    }

    /// 初始化 - 从日期集合创建
    init(dates: Set<Date>) {
        self.id = UUID()
        self.dateIntervals = dates.map { $0.startOfDay().timeIntervalSince1970 }.sorted()
    }

    /// 初始化 - 从单个开始日期创建（兼容旧数据）
    init(startDate: Date, duration: Int = 6) {
        self.id = UUID()
        var allDates: [TimeInterval] = []
        for i in 0..<duration {
            let date = startDate.adding(days: i).startOfDay()
            allDates.append(date.timeIntervalSince1970)
        }
        self.dateIntervals = allDates.sorted()
    }

    // MARK: - Equatable

    static func == (lhs: PeriodRecord, rhs: PeriodRecord) -> Bool {
        return lhs.id == rhs.id && lhs.dateIntervals == rhs.dateIntervals
    }
}
