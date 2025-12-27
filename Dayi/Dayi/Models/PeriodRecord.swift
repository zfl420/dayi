import Foundation

/// 月经记录模型
struct PeriodRecord: Codable, Equatable {
    /// 经期开始日 S
    let startDate: Date

    /// 经期结束日 S+6（计算属性）
    var endDate: Date {
        return startDate.adding(days: 6)
    }

    /// 初始化
    /// - Parameter startDate: 经期开始日期
    init(startDate: Date) {
        self.startDate = startDate.startOfDay()
    }
}
