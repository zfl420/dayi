import SwiftUI

/// 月份标题视图（用于日期选择器的月份分隔）
struct MonthHeaderView: View {
    let monthSection: MonthSection
    let geometry: GeometryProxy
    let isFirst: Bool // 是否是第一个月份（控制顶部间距和年份显示）

    // 获取标题文本（每年1月显示年份）
    private var headerText: String {
        return monthSection.getHeaderText()
    }

    var body: some View {
        HStack(spacing: geometry.size.width * 0.02) {
            // 左边横线
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)

            // 月份文字
            Text(headerText)
                .font(.pingFang(size: geometry.size.height * 0.025, weight: .medium))
                .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
                .fixedSize(horizontal: true, vertical: false)

            // 右边横线
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.top, isFirst ? 0 : geometry.size.height * 0.015)
        .padding(.bottom, geometry.size.height * 0.01)
    }
}
