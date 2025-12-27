import Foundation

enum DateState: Equatable {
    case normal              // 普通日期
    case selected            // 当前选中
    case disabled            // 禁用日期（不可选）
    case afterPeriodDashed   // 选中后6天（虚线）
}
