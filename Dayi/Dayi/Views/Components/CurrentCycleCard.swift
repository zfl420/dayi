import SwiftUI

/// 当前进行中的周期卡片
struct CurrentCycleCard: View {
    let cycleData: CurrentCycleData
    let averageDays: Int?
    let maxCycleDays: Int
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.0188) {
            Text("当前周期：\(cycleData.dateRangeText)")
                .font(.pingFang(size: geometry.size.height * 0.0188, weight: .medium))
                .foregroundColor(Color("Hex999999"))

            ZStack(alignment: .leading) {
                // 底层：未过日期（浅灰色）- 最长
                Rectangle()
                    .fill(Color("HexE4E4E4"))
                    .frame(width: scaledBarWidth, height: geometry.size.height * 0.027)
                    .cornerRadius(geometry.size.height * 0.0135)

                // 中层：已过日期（中灰色）+ 天数文本
                HStack(alignment: .center, spacing: geometry.size.width * 0.0204) {
                    Rectangle()
                        .fill(Color("HexCDCDCD"))
                        .frame(width: scaledBarWidth * elapsedRatio, height: geometry.size.height * 0.027)
                        .cornerRadius(geometry.size.height * 0.0135)

                    Text("\(cycleData.elapsedDays) 天")
                        .font(.pingFang(size: geometry.size.height * 0.0211, weight: .medium))
                        .foregroundColor(Color("Hex111827"))

                    Spacer(minLength: 0)
                }

                // 顶层：经期日期（红色）- 最短
                Rectangle()
                    .fill(Color("HexFF678B"))
                    .frame(width: scaledBarWidth * periodRatio, height: geometry.size.height * 0.0325)
                    .cornerRadius(geometry.size.height * 0.0163)
            }
            .frame(height: geometry.size.height * 0.0325)
        }
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0235)
    }

    private var actualCycleDays: Int {
        max(cycleData.elapsedDays, cycleData.predictedTotalDays)
    }

    private var elapsedRatio: CGFloat {
        CGFloat(cycleData.elapsedDays) / CGFloat(actualCycleDays)
    }

    private var periodRatio: CGFloat {
        CGFloat(cycleData.predictedPeriodDays) / CGFloat(actualCycleDays)
    }

    private var maxBarWidth: CGFloat {
        let textSpaceWidth = geometry.size.width * 0.15
        return geometry.size.width - 2 * geometry.size.width * 0.0509 - 2 * geometry.size.width * 0.0407 - textSpaceWidth
    }

    private var scaledBarWidth: CGFloat {
        let ratio = CGFloat(actualCycleDays) / CGFloat(maxCycleDays)
        return maxBarWidth * ratio
    }
}
