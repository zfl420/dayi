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
                .font(.system(size: geometry.size.height * 0.0188, weight: .medium))
                .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))

            HStack(alignment: .center, spacing: geometry.size.width * 0.0204) {
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(red: 205/255, green: 205/255, blue: 205/255))
                            .frame(width: scaledBarWidth * elapsedRatio)

                        Rectangle()
                            .fill(Color(red: 228/255, green: 228/255, blue: 228/255))
                            .frame(width: scaledBarWidth * (1 - elapsedRatio))
                    }
                    .frame(height: geometry.size.height * 0.0236)
                    .cornerRadius(geometry.size.height * 0.0118)

                    Rectangle()
                        .fill(Color(red: 250/255, green: 100/255, blue: 100/255))
                        .frame(width: scaledBarWidth * periodRatio, height: geometry.size.height * 0.0325)
                        .cornerRadius(geometry.size.height * 0.0163)
                }
                .frame(width: scaledBarWidth, height: geometry.size.height * 0.0325)

                Text("\(cycleData.elapsedDays) 天")
                    .font(.system(size: geometry.size.height * 0.0211, weight: .medium))
                    .foregroundColor(.black)

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0235)
    }

    private var elapsedRatio: CGFloat {
        CGFloat(cycleData.elapsedDays) / CGFloat(cycleData.predictedTotalDays)
    }

    private var periodRatio: CGFloat {
        CGFloat(cycleData.periodDays) / CGFloat(cycleData.predictedTotalDays)
    }

    private var maxBarWidth: CGFloat {
        let textSpaceWidth = geometry.size.width * 0.15
        return geometry.size.width - 2 * geometry.size.width * 0.0509 - 2 * geometry.size.width * 0.0407 - textSpaceWidth
    }

    private var scaledBarWidth: CGFloat {
        let ratio = CGFloat(cycleData.predictedTotalDays) / CGFloat(maxCycleDays)
        return maxBarWidth * ratio
    }
}
