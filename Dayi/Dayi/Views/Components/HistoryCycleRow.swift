import SwiftUI

/// 历史周期列表项
struct HistoryCycleRow: View {
    let cycle: CycleData
    let averageDays: Int?
    let maxCycleDays: Int
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.0141) {
            Text(cycle.dateRangeText)
                .font(.pingFang(size: geometry.size.height * 0.0188, weight: .medium))
                .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))

            HStack(alignment: .center, spacing: geometry.size.width * 0.0204) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(red: 205/255, green: 205/255, blue: 205/255))
                        .frame(width: scaledBarWidth, height: geometry.size.height * 0.027)
                        .cornerRadius(geometry.size.height * 0.0135)

                    Rectangle()
                        .fill(Color(red: 255/255, green: 103/255, blue: 139/255))
                        .frame(width: scaledBarWidth * periodRatio, height: geometry.size.height * 0.0325)
                        .cornerRadius(geometry.size.height * 0.0163)
                }
                .frame(width: scaledBarWidth, height: geometry.size.height * 0.0325)

                Text("\(cycle.cycleDays) 天")
                    .font(.pingFang(size: geometry.size.height * 0.0211, weight: .medium))
                    .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0188)
    }

    private var periodRatio: CGFloat {
        guard cycle.cycleDays > 0 else { return 0 }
        return CGFloat(cycle.periodDays) / CGFloat(cycle.cycleDays)
    }

    private var maxBarWidth: CGFloat {
        let textSpaceWidth = geometry.size.width * 0.15
        return geometry.size.width - 2 * geometry.size.width * 0.0509 - 2 * geometry.size.width * 0.0407 - textSpaceWidth
    }

    private var scaledBarWidth: CGFloat {
        let safeMax = max(maxCycleDays, 1)
        let ratio = CGFloat(cycle.cycleDays) / CGFloat(safeMax)
        return maxBarWidth * max(min(ratio, 1), 0)
    }
}
