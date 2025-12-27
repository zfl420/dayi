import SwiftUI

/// 日期选择器内容区域
struct DatePickerContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    // 生成从1年前到未来4周的日期数据（减少数据量以提升性能）
    private var weeks: [[Date]] {
        var allWeeks: [[Date]] = []
        let today = Date().startOfDay()
        let calendar = Calendar.current

        // 从1年前开始（而不是5年前，减少数据量）
        let startDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today.adding(days: -365)
        let startWeekDate = startDate.getWeekStart()

        // 计算需要多少周（1年 + 4周，约56周）
        let endDate = today.adding(days: 4 * 7)
        let totalDays = calendar.dateComponents([.day], from: startWeekDate, to: endDate).day ?? 0
        let totalWeeks = (totalDays / 7) + 1

        // 生成所有周的数据
        for weekIndex in 0..<totalWeeks {
            let weekStart = calendar.date(byAdding: .day, value: weekIndex * 7, to: startWeekDate)!
            var week: [Date] = []

            for dayIndex in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayIndex, to: weekStart) {
                    week.append(date)
                }
            }

            if !week.isEmpty {
                allWeeks.append(week)
            }
        }

        return allWeeks
    }

    // 判断某周是否需要显示月份标题
    private func shouldShowMonthHeader(for week: [Date], atIndex index: Int) -> Bool {
        guard let firstDate = week.first else { return false }

        // 第一周总是显示
        if index == 0 {
            return true
        }

        // 如果这周的月份与上一周的月份不同，则显示
        guard index > 0, let previousWeekFirstDate = weeks[index - 1].first else {
            return false
        }

        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: firstDate)
        let previousMonth = calendar.component(.month, from: previousWeekFirstDate)

        return currentMonth != previousMonth
    }

    // 获取月份标题文本
    private func getMonthHeaderText(for week: [Date]) -> String {
        guard let firstDate = week.first else { return "" }
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        let month = calendar.component(.month, from: firstDate)
        let year = calendar.component(.year, from: firstDate)

        // 1月显示年份
        if month == 1 {
            return "\(month)月, \(year)"
        } else {
            return "\(month)月"
        }
    }

    // 找到选中日期所在周的索引
    private var selectedWeekIndex: Int? {
        let selectedDate = viewModel.tempSelectedDate
        return weeks.firstIndex { week in
            week.contains { date in
                date.isSameDay(as: selectedDate)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 周标题
            HStack(spacing: geometry.size.width * 0.01) {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: geometry.size.height * 0.0205, weight: .semibold))
                        .foregroundColor(Color(red: 90/255.0, green: 87/255.0, blue: 86/255.0))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, geometry.size.width * 0.03)
            .padding(.vertical, geometry.size.height * 0.01)

            // 日期内容
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: geometry.size.height * 0.01) {
                        ForEach(weeks.indices, id: \.self) { index in
                            VStack(spacing: geometry.size.height * 0.005) {
                                // 月份标题
                                if shouldShowMonthHeader(for: weeks[index], atIndex: index) {
                                    HStack(spacing: geometry.size.width * 0.02) {
                                        // 左边横线
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 1)

                                        // 月份文字
                                        Text(getMonthHeaderText(for: weeks[index]))
                                            .font(.system(size: geometry.size.height * 0.0188, weight: .medium))
                                            .foregroundColor(Color(red: 100/255.0, green: 100/255.0, blue: 100/255.0))

                                        // 右边横线
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                    .padding(.top, index == 0 ? 0 : geometry.size.height * 0.015)
                                    .padding(.bottom, geometry.size.height * 0.01)
                                }

                                // 周行
                                DatePickerWeekRow(
                                    dates: weeks[index],
                                    viewModel: viewModel,
                                    geometry: geometry
                                )
                            }
                            .id(index)
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                    .background(Color(red: 248/255.0, green: 243/255.0, blue: 241/255.0))
                }
                .background(Color(red: 248/255.0, green: 243/255.0, blue: 241/255.0))
                .onAppear {
                    // 滚动到选中日期所在周
                    if let index = selectedWeekIndex {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            proxy.scrollTo(index, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
