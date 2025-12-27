import SwiftUI

/// 日期选择器中的一周行
struct DatePickerWeekRow: View {
    let dates: [Date]
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        HStack(spacing: geometry.size.width * 0.01) {
            ForEach(dates, id: \.self) { date in
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
