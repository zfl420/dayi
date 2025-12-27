import SwiftUI

struct WeekCalendar: View {
    @ObservedObject var viewModel: PeriodViewModel

    let weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        VStack(spacing: 12) {
            // 星期标签行
            HStack(spacing: 0) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)

            // 日期格子行
            HStack(spacing: 8) {
                ForEach(viewModel.currentWeekDates, id: \.self) { date in
                    let state = viewModel.getStateForDate(date)

                    DayCell(date: date, state: state)
                        .onTapGesture {
                            viewModel.selectDate(date)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .gesture(swipeGesture)
        .transition(.opacity)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if value.translation.width < -30 {
                        viewModel.moveToNextWeek()
                    } else if value.translation.width > 30 {
                        viewModel.moveToPreviousWeek()
                    }
                }
            }
    }
}
