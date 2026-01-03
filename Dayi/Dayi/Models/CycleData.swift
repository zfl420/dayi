import Foundation

/// 已完成的周期数据
struct CycleData: Identifiable {
    let id = UUID()
    let periodStartDate: Date      // 本次经期开始日
    let periodEndDate: Date        // 本次经期结束日
    let nextPeriodStartDate: Date  // 下次经期开始日
    let cycleDays: Int             // 周期天数
    let periodDays: Int            // 经期天数

    /// 周期日期范围文本
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")

        let startText = formatter.string(from: periodStartDate)
        let endText = formatter.string(from: nextPeriodStartDate.adding(days: -1))

        return "\(startText) - \(endText)"
    }
}

/// 当前进行中的周期数据
struct CurrentCycleData {
    let cycleStartDate: Date       // 周期开始日
    let periodStartDate: Date      // 经期开始日
    let periodEndDate: Date        // 经期结束日
    let elapsedDays: Int           // 已进行天数
    let predictedTotalDays: Int    // 预计总天数
    let predictedEndDate: Date     // 预测结束日期
    let periodDays: Int            // 经期天数（实际已记录）
    let predictedPeriodDays: Int   // 预测经期天数（用于进度条显示）

    /// 周期日期范围文本
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")

        let startText = formatter.string(from: cycleStartDate)
        let endText = formatter.string(from: predictedEndDate)

        return "\(startText) - \(endText)"
    }
}

/// 历史经期数据
struct PeriodData: Identifiable {
    let id = UUID()
    let periodStartDate: Date
    let periodEndDate: Date
    let periodDays: Int

    /// 经期日期范围文本
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")

        let startText = formatter.string(from: periodStartDate)
        let endText = formatter.string(from: periodEndDate)

        return "\(startText) - \(endText)"
    }
}

/// 当前进行中的经期数据
struct CurrentPeriodData {
    let periodStartDate: Date
    let periodEndDate: Date
    let elapsedPeriodDays: Int
    let predictedPeriodDays: Int

    /// 经期日期范围文本
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")

        let today = Date().startOfDay()
        let startText = formatter.string(from: periodStartDate)
        let endText = formatter.string(from: today)

        return "\(startText) - \(endText)"
    }
}
