import SwiftUI

/// 贯穿所有经期的平均参考线组件
struct PeriodAverageReferenceLine: View {
    let averageDays: Int?
    let maxPeriodDays: Int
    let geometry: GeometryProxy

    var body: some View {
        if let avgDays = averageDays {
            VStack(spacing: 0) {
                Text("平均")
                    .font(.pingFang(size: geometry.size.height * 0.0164, weight: .medium))
                    .foregroundColor(Color("HexB4B4B4"))
                    .padding(.bottom, geometry.size.height * 0.003)

                DashedVerticalLine(color: Color("Hex111827").opacity(0.3))
                    .frame(width: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: calculateXOffset(avgDays: avgDays))
        }
    }

    private func calculateXOffset(avgDays: Int) -> CGFloat {
        // 进度条左侧内边距
        let barPadding = geometry.size.width * 0.0407
        // 卡片内边距
        let cardPadding = geometry.size.width * 0.0509
        // 文本区域宽度
        let textSpaceWidth = geometry.size.width * 0.15
        // 进度条最大宽度
        let maxBarWidth = geometry.size.width - 2 * cardPadding - 2 * barPadding - textSpaceWidth

        // 平均天数在最大天数中的比例
        let ratio = CGFloat(avgDays) / CGFloat(maxPeriodDays)

        // 平均线的位置
        return barPadding + maxBarWidth * ratio
    }
}
