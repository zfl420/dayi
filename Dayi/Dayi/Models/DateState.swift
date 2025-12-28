import Foundation

/// 日期状态枚举（简化版）
enum DateState: Equatable {
    case normal     // 普通日期（未选中）
    case selected   // 已选中
    case extendable // 可扩展日期（当前经期段的下一天）
    case disabled   // 禁用（远期未来日期）
}
