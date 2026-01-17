import SwiftUI

/// 历史经期列表项
struct HistoryPeriodRow: View {
    let period: PeriodData
    let averageDays: Int?
    let maxPeriodDays: Int
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.0141) {
            Text(period.dateRangeText)
                .font(.pingFang(size: geometry.size.height * 0.0188, weight: .medium))
                .foregroundColor(Color("HexB4B4B4"))

            HStack(alignment: .center, spacing: geometry.size.width * 0.0204) {
                RoundedRectangle(cornerRadius: geometry.size.height * 0.0135)
                    .fill(Color("HexFF678B"))
                    .frame(width: scaledBarWidth, height: geometry.size.height * 0.027)

                Text("\(period.periodDays) 天")
                    .font(.pingFang(size: geometry.size.height * 0.0211, weight: .medium))
                    .foregroundColor(Color("HexFF678B"))

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0188)
    }

    private var maxBarWidth: CGFloat {
        let textSpaceWidth = geometry.size.width * 0.15
        return geometry.size.width - 2 * geometry.size.width * 0.0509 - 2 * geometry.size.width * 0.0407 - textSpaceWidth
    }

    private var scaledBarWidth: CGFloat {
        let ratio = CGFloat(period.periodDays) / CGFloat(maxPeriodDays)
        return maxBarWidth * ratio
    }
}
