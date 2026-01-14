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
                .font(.system(size: geometry.size.height * 0.0188, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))

            HStack(alignment: .center, spacing: geometry.size.width * 0.0204) {
                RoundedRectangle(cornerRadius: geometry.size.height * 0.0135)
                    .fill(Color(red: 255/255, green: 90/255, blue: 125/255))
                    .frame(width: scaledBarWidth, height: geometry.size.height * 0.027)

                Text("\(period.periodDays) 天")
                    .font(.system(size: geometry.size.height * 0.0211, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 255/255, green: 90/255, blue: 125/255))

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
