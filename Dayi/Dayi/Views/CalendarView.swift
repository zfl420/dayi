import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: PeriodViewModel
    @State private var isYearView: Bool = true
    @State private var targetMonthId: String? = nil

    var body: some View {
        GeometryReader { geometry in
            let toolbarFontSize = geometry.size.height * 0.0188
            Group {
                if isYearView {
                    YearCalendarContent(viewModel: viewModel, geometry: geometry) { month in
                        targetMonthId = month.id
                        isYearView = false
                    }
                } else {
                    CalendarContent(
                        viewModel: viewModel,
                        geometry: geometry,
                        targetMonthId: targetMonthId
                    ) {
                        targetMonthId = nil
                    }
                }
            }
            .navigationTitle("日历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isYearView.toggle() }) {
                        Text(isYearView ? "月视图" : "年视图")
                            .font(.pingFang(size: toolbarFontSize, weight: .medium))
                            .foregroundColor(Color("Hex111827"))
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView(viewModel: PeriodViewModel())
}
