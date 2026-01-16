import SwiftUI

/// 周期统计顶部汇总区域
struct CycleStatsHeader: View {
    let averageDays: Int?
    let geometry: GeometryProxy

    var body: some View {
        HStack(spacing: geometry.size.width * 0.0153) {
            Text("你的平均周期天数:")
                .font(.pingFang(size: geometry.size.height * 0.024, weight: .bold))
                .foregroundColor(Color("Hex111827"))

            if let days = averageDays {
                Text("\(days) 天")
                    .font(.pingFang(size: geometry.size.height * 0.024, weight: .bold))
                    .foregroundColor(Color("Hex111827"))
            } else {
                Text("暂无数据")
                    .font(.pingFang(size: geometry.size.height * 0.024, weight: .bold))
                    .foregroundColor(Color("Hex111827"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, geometry.size.width * 0.0407)
        .padding(.vertical, geometry.size.height * 0.0282)
    }
}
