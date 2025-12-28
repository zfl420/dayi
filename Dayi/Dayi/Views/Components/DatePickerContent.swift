import SwiftUI

/// 用于检测视图可见性的 PreferenceKey
struct VisibleWeekPreferenceKey: PreferenceKey {
    static var defaultValue: Set<Int> = []

    static func reduce(value: inout Set<Int>, nextValue: () -> Set<Int>) {
        value.formUnion(nextValue())
    }
}

/// 日期选择器内容区域
struct DatePickerContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    var topBackgroundColor: Color = Color(red: 250/255.0, green: 250/255.0, blue: 250/255.0)  // #FAFAFA

    // 起始日期：1970年1月1日的周一（Unix Epoch）
    private var startWeekDate: Date {
        Date(timeIntervalSince1970: 0).getWeekStart()
    }

    // 总周数（从1970年到今天的下两周）
    private var totalWeeks: Int {
        let today = Date().startOfDay()
        // 今天的下两周的周日 = 今天所在周的周一 + 2周 + 6天
        let todayWeekStart = today.getWeekStart()
        let endDate = todayWeekStart.adding(days: 2 * 7 + 6)  // 下两周的周日
        let totalDays = Calendar.current.dateComponents([.day], from: startWeekDate, to: endDate).day ?? 0
        return (totalDays / 7) + 1
    }

    // 根据索引获取该周的日期（懒加载，只在需要时计算）
    private func getWeekDates(for index: Int) -> [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(byAdding: .day, value: index * 7, to: startWeekDate) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    // 判断某周是否需要显示月份标题（基于索引）
    private func shouldShowMonthHeader(for index: Int) -> Bool {
        // 第一周总是显示
        if index == 0 {
            return true
        }

        let currentWeek = getWeekDates(for: index)
        let previousWeek = getWeekDates(for: index - 1)

        guard let currentFirst = currentWeek.first, let previousFirst = previousWeek.first else {
            return false
        }

        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentFirst)
        let previousMonth = calendar.component(.month, from: previousFirst)

        return currentMonth != previousMonth
    }

    // 获取月份标题文本
    private func getMonthHeaderText(for index: Int) -> String {
        let week = getWeekDates(for: index)
        guard let firstDate = week.first else { return "" }
        let calendar = Calendar.current

        let month = calendar.component(.month, from: firstDate)
        let year = calendar.component(.year, from: firstDate)

        // 1月显示年份
        if month == 1 {
            return "\(month)月, \(year)"
        } else {
            return "\(month)月"
        }
    }

    // 今天所在周的索引
    private var todayWeekIndex: Int {
        let today = Date().startOfDay()
        let days = Calendar.current.dateComponents([.day], from: startWeekDate, to: today).day ?? 0
        return days / 7
    }


    var body: some View {
        VStack(spacing: 0) {
            // 周标题
            HStack(spacing: geometry.size.width * 0.01) {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                        .foregroundColor(Color(red: 90/255.0, green: 87/255.0, blue: 86/255.0))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, geometry.size.width * 0.03)
            .padding(.top, geometry.size.height * 0.03)  // 顶部留较大间距（弹窗横条占用空间）
            .padding(.bottom, geometry.size.height * 0.0075)  // 底部留小间距
            .background(topBackgroundColor)

            // 日期内容
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: geometry.size.height * 0.01) {
                        ForEach(0..<totalWeeks, id: \.self) { index in
                            VStack(spacing: geometry.size.height * 0.005) {
                                // 月份标题
                                if shouldShowMonthHeader(for: index) {
                                    HStack(spacing: geometry.size.width * 0.02) {
                                        // 左边横线
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 1)

                                        // 月份文字
                                        Text(getMonthHeaderText(for: index))
                                            .font(.system(size: geometry.size.height * 0.025, weight: .medium))
                                            .foregroundColor(.black)
                                            .fixedSize(horizontal: true, vertical: false)

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
                                    dates: getWeekDates(for: index),
                                    viewModel: viewModel,
                                    geometry: geometry
                                )
                            }
                            .id(index)
                            // 检测今天所在周的可见性
                            .background(
                                GeometryReader { itemGeometry in
                                    Color.clear
                                        .preference(
                                            key: VisibleWeekPreferenceKey.self,
                                            value: isWeekVisible(itemGeometry: itemGeometry, in: geometry, weekIndex: index) ? [index] : []
                                        )
                                }
                            )
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                    .background(Color.white)
                }
                .background(Color.white)
                .onPreferenceChange(VisibleWeekPreferenceKey.self) { visibleWeeks in
                    // 检查今天所在周是否可见
                    let isTodayCurrentlyVisible = visibleWeeks.contains(todayWeekIndex)
                    if viewModel.isTodayVisible != isTodayCurrentlyVisible {
                        viewModel.isTodayVisible = isTodayCurrentlyVisible
                    }
                }
                .onAppear {
                    // 初始滚动：直接定位到最底部（最后一周）
                    proxy.scrollTo(totalWeeks - 1, anchor: .bottom)
                }
                .onChange(of: viewModel.scrollToTodayTrigger) {
                    // 点击"今天"按钮：滚动到今天所在周
                    withAnimation {
                        proxy.scrollTo(todayWeekIndex, anchor: .center)
                    }
                }
            }
        }
    }

    // 检测周是否在可见范围内
    private func isWeekVisible(itemGeometry: GeometryProxy, in containerGeometry: GeometryProxy, weekIndex: Int) -> Bool {
        let itemFrame = itemGeometry.frame(in: .global)
        let containerFrame = containerGeometry.frame(in: .global)

        // 检查 item 是否与容器有交集
        return itemFrame.maxY > containerFrame.minY && itemFrame.minY < containerFrame.maxY
    }
}
