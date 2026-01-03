import SwiftUI

/// 当前进行中的经期卡片
struct CurrentPeriodCard: View {
    let periodData: CurrentPeriodData
    let averageDays: Int?
    let maxPeriodDays: Int
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.0188) {
            Text("当前经期：\(periodData.dateRangeText)")
                .font(.system(size: geometry.size.height * 0.0188, weight: .medium))
                .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))

            ZStack(alignment: .leading) {
                // 底层：浅红色背景
                RoundedRectangle(cornerRadius: geometry.size.height * 0.0135)
                    .fill(Color(red: 255/255, green: 210/255, blue: 218/255))
                    .frame(width: scaledBarWidth, height: geometry.size.height * 0.027)

                // 顶层：深红色进度
                RoundedRectangle(cornerRadius: geometry.size.height * 0.0135)
                    .fill(Color(red: 255/255, green: 90/255, blue: 125/255))
                    .frame(width: scaledBarWidth * periodRatio, height: geometry.size.height * 0.027)
                    .overlay(
                        // 天数文字定位在深红色进度条右侧末端
                        Text("\(periodData.elapsedPeriodDays) 天")
                            .font(.system(size: geometry.size.height * 0.0211, weight: .medium))
                            .foregroundColor(Color(red: 255/255, green: 90/255, blue: 125/255))
                            .offset(x: scaledBarWidth * periodRatio + geometry.size.width * 0.0204, y: 0)
                        , alignment: .leading
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: geometry.size.height * 0.027)
        }
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0235)
    }

    private var actualPeriodDays: Int {
        max(periodData.elapsedPeriodDays, periodData.predictedPeriodDays)
    }

    private var periodRatio: CGFloat {
        CGFloat(periodData.elapsedPeriodDays) / CGFloat(actualPeriodDays)
    }

    private var maxBarWidth: CGFloat {
        let textSpaceWidth = geometry.size.width * 0.15
        return geometry.size.width - 2 * geometry.size.width * 0.0509 - 2 * geometry.size.width * 0.0407 - textSpaceWidth
    }

    private var scaledBarWidth: CGFloat {
        let ratio = CGFloat(actualPeriodDays) / CGFloat(maxPeriodDays)
        return maxBarWidth * ratio
    }
}
