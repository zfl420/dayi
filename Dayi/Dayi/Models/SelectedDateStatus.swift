//
//  SelectedDateStatus.swift
//  Dayi
//
//  Created by Claude on 2025-12-30.
//

import Foundation

/// 选中日期的状态枚举
enum SelectedDateStatus {
    /// 在所有经期之前（无历史记录或早于最早记录）
    case beforeAllPeriods

    /// 在某个经期内
    /// - Parameter dayNumber: 当前经期的第几天（从1开始）
    case inPeriod(dayNumber: Int)

    /// 在经期之后（非经期日期）
    /// - Parameter daysSinceLastPeriodStart: 距离最近上一个经期开始日的天数
    /// - Parameter isCurrentCycle: 是否属于当前周期（最新周期）
    case afterPeriod(daysSinceLastPeriodStart: Int, isCurrentCycle: Bool)

    /// 是否在经期内
    var isInPeriod: Bool {
        if case .inPeriod = self {
            return true
        }
        return false
    }
}
