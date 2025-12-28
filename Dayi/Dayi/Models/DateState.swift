import Foundation

enum DateState: Equatable {
    case normal              // 普通日期
    case selected            // 当前选中
    case disabled            // 禁用日期（不可选）
    case afterPeriodDashed   // 选中后5天（虚线），共6天经期
    case extendable          // 可扩展日期 - 今天之后（灰色虚线框，无勾）
    case extendablePast      // 可扩展日期 - 今天及之前（灰色实线框，无勾）
    case extended            // 已扩展选中的日期（红色虚线框）
}
