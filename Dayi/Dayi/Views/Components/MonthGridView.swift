import SwiftUI

/// 月份日期网格视图（用于日期选择器的单月日期展示）
struct MonthGridView: View {
    let monthSection: MonthSection
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    // 7列网格布局（周一到周日）
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: geometry.size.height * 0.01) {
            // 前置空白占位（对齐星期列）
            ForEach(0..<monthSection.leadingBlankCount, id: \.self) { _ in
                Color.clear
                    .frame(
                        width: geometry.size.width / 7 - geometry.size.width * 0.01,
                        height: geometry.size.width / 7 - geometry.size.width * 0.01
                    )
            }

            // 该月所有日期
            ForEach(monthSection.days, id: \.self) { date in
                DatePickerDayCell(
                    viewModel: viewModel,
                    date: date,
                    geometry: geometry
                )
            }
        }
        .padding(.horizontal, geometry.size.width * 0.03)
    }
}
