import SwiftUI

struct WeekCalendar: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let isTodayInPeriod: Bool

    let weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"]
    @State private var currentPage = 1 // 从中间页开始

    var body: some View {
        VStack(spacing: geometry.size.height * 0.0094) { // 8/852
            // 星期标签行
            HStack(spacing: geometry.size.width * 0.0056) { // 2.2/393 (考虑左右内边距后的间距)
                ForEach(Array(viewModel.currentWeekDates.enumerated()), id: \.element) { index, date in
                    Text(getLabelForDate(date, index: index))
                        .font(.system(size: geometry.size.height * 0.0141, weight: date.isSameDay(as: Date()) ? .bold : .medium)) // 12/852，今天加粗
                        .foregroundColor(date.isSameDay(as: Date()) ? .black : Color(red: 90/255.0, green: 87/255.0, blue: 86/255.0))
                        .frame(width: geometry.size.width * 0.1272) // 50/393 (与日期圆形大小一致)
                }
            }

            // 日期格子行 - 背景和内容分离
            ZStack {
                // 固定的背景圆形层（只显示选中日期的背景）
                HStack(spacing: geometry.size.width * 0.0056) {
                    ForEach(0..<7, id: \.self) { index in
                        let date = viewModel.currentWeekDates[safe: index]

                        // 根据选中日期是否在月经期选择不同的选中圆颜色
                        let selectedColor = isTodayInPeriod
                            ? Color.white
                            : Color(red: 220/255, green: 213/255, blue: 210/255)  // #DCD5D2

                        Circle()
                            .fill(date != nil && viewModel.getStateForDate(date!) == .selected
                                  ? selectedColor
                                  : Color.clear)
                            .frame(width: geometry.size.width * 0.1272, height: geometry.size.width * 0.1272)
                    }
                }

                // 可滚动的日期内容层
                TabView(selection: $currentPage) {
                    // 前一周
                    WeekDatesRow(dates: getPreviousWeekDates(), viewModel: viewModel, geometry: geometry, showBackground: false)
                        .tag(0)

                    // 当前周
                    WeekDatesRow(dates: viewModel.currentWeekDates, viewModel: viewModel, geometry: geometry, showBackground: false)
                        .tag(1)

                    // 下一周
                    WeekDatesRow(dates: getNextWeekDates(), viewModel: viewModel, geometry: geometry, showBackground: false)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: geometry.size.width * 0.1272) // 50/393 圆形高度
                .onChange(of: currentPage) { _, newPage in
                    handlePageChange(newPage)
                }
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0381) // 15/393 左右各留15像素边距
        .frame(maxWidth: .infinity)
    }

    private func handlePageChange(_ page: Int) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if page == 0 {
            // 滑到前一周
            viewModel.moveToPreviousWeek()
            currentPage = 1
        } else if page == 2 {
            // 滑到下一周
            viewModel.moveToNextWeek()
            currentPage = 1
        }
    }

    private func getPreviousWeekDates() -> [Date] {
        let weekStart = viewModel.selectedDate.adding(days: -7).getWeekStart()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    private func getNextWeekDates() -> [Date] {
        let weekStart = viewModel.selectedDate.adding(days: 7).getWeekStart()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    private func getLabelForDate(_ date: Date, index: Int) -> String {
        if date.isSameDay(as: Date()) {
            return "今天"
        }
        return weekdayLabels[index]
    }
}

// 单独的一行日期组件
struct WeekDatesRow: View {
    let dates: [Date]
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    var showBackground: Bool = true

    var body: some View {
        HStack(spacing: geometry.size.width * 0.0056) { // 2.2/393 (考虑左右内边距后的间距)
            ForEach(dates, id: \.self) { date in
                DayCellContent(
                    date: date,
                    state: viewModel.getStateForDate(date),
                    geometry: geometry,
                    showBackground: showBackground
                )
                .environmentObject(viewModel)
                .onTapGesture {
                    // 触发震动反馈
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    viewModel.selectDate(date)
                }
            }
        }
    }
}

// 日期单元格内容（不含背景）
struct DayCellContent: View {
    let date: Date
    let state: DateState
    let geometry: GeometryProxy
    var showBackground: Bool = true
    @EnvironmentObject var viewModel: PeriodViewModel

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var fontWeight: Font.Weight {
        if isToday {
            return .semibold
        } else {
            return .regular
        }
    }

    private var cellSize: CGFloat {
        return geometry.size.width * 0.1272  // 50/393
    }

    private var smallCircleSize: CGFloat {
        return cellSize * 0.75  // 小圆为选中圆的 75%
    }

    var body: some View {
        ZStack {
            // 1. 底层：原有白色选中圆（保持不变）
            if showBackground && state == .selected {
                Circle()
                    .fill(Color(red: 220/255.0, green: 213/255.0, blue: 210/255.0))
                    .frame(width: cellSize, height: cellSize)
            }

            // 2. 中层：新增背景圈
            if viewModel.shouldShowPeriodBackground(date) {
                // 实心浅红小圆（记录日至今天）
                Circle()
                    .fill(Color(red: 255.0/255.0, green: 90.0/255.0, blue: 125.0/255.0))
                    .frame(width: smallCircleSize, height: smallCircleSize)
            } else if viewModel.shouldShowPredictionBorder(date) {
                // 空心红色圆点虚线小圆（今天至第七天）
                DottedCircle(dotCount: 18, dotRadius: 1.5)
                    .foregroundColor(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
                    .frame(width: smallCircleSize, height: smallCircleSize)
            }

            // 3. 顶层：日期文字（保持不变）
            VStack(spacing: geometry.size.height * 0.0023) { // 2/852
                Text(date.shortDateString)
                    .font(.system(size: geometry.size.height * 0.0229, weight: fontWeight)) // 19.5/852
                    .foregroundColor(viewModel.shouldShowPeriodBackground(date) ? .white : .black)

                if isToday {
                    Circle()
                        .fill(viewModel.shouldShowPeriodBackground(date) ? .white : Color(red: 0.6, green: 0.6, blue: 0.6))
                        .frame(width: geometry.size.height * 0.0047, height: geometry.size.height * 0.0047) // 4/852
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
    }
}

// Array 安全访问扩展
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
