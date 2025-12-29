import SwiftUI

/// 用于检测视图可见性的 PreferenceKey（改为检测月份索引）
struct VisibleMonthPreferenceKey: PreferenceKey {
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

    // 日期范围：从1970年1月1日到今天的下两周
    private var startDate: Date {
        Date(timeIntervalSince1970: 0).startOfDay()
    }

    private var endDate: Date {
        let today = Date().startOfDay()
        return Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
    }

    // 按月分段的数据（懒加载）
    private var monthSections: [MonthSection] {
        MonthSection.generateMonthSections(from: startDate, to: endDate)
    }

    // 今天所在月的索引
    private var todayMonthIndex: Int {
        let today = Date().startOfDay()
        let calendar = Calendar.current
        let todayYear = calendar.component(.year, from: today)
        let todayMonth = calendar.component(.month, from: today)

        return monthSections.firstIndex { section in
            section.year == todayYear && section.month == todayMonth
        } ?? (monthSections.count - 1)
    }


    var body: some View {
        ZStack(alignment: .top) {
            // 日历滚动区域（全屏）
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 顶部占位空间（为星期标题留空）
                        // 计算：上边距 + 星期标题高度 + 底部边距 + 缓冲
                        Color.clear
                            .frame(height: max(geometry.safeAreaInsets.top - 10, 10) + geometry.size.height * 0.0141 + geometry.size.height * 0.0075 + 10)

                        // 按月渲染（每个月是独立的 Section）
                        ForEach(Array(monthSections.enumerated()), id: \.element.id) { index, section in
                            VStack(spacing: geometry.size.height * 0.005) {
                                // 月份标题
                                MonthHeaderView(
                                    monthSection: section,
                                    geometry: geometry,
                                    isFirst: index == 0
                                )

                                // 该月日期网格
                                MonthGridView(
                                    monthSection: section,
                                    viewModel: viewModel,
                                    geometry: geometry
                                )
                            }
                            .id(index)
                            // 检测今天所在月的可见性
                            .background(
                                GeometryReader { itemGeometry in
                                    Color.clear
                                        .preference(
                                            key: VisibleMonthPreferenceKey.self,
                                            value: isMonthVisible(itemGeometry: itemGeometry, in: geometry, monthIndex: index) ? [index] : []
                                        )
                                }
                            )
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                    .background(Color.white)
                }
                .background(Color.white)
                .onPreferenceChange(VisibleMonthPreferenceKey.self) { visibleMonths in
                    // 检查今天所在月是否可见
                    let isTodayCurrentlyVisible = visibleMonths.contains(todayMonthIndex)
                    if viewModel.isTodayVisible != isTodayCurrentlyVisible {
                        viewModel.isTodayVisible = isTodayCurrentlyVisible
                    }
                }
                .task {
                    // 步骤1：延迟加载数据（等待1帧让视图稳定）
                    try? await Task.sleep(nanoseconds: 16_666_666) // ~16ms
                    viewModel.loadDatePickerData()

                    // 步骤2：等待数据渲染完成
                    try? await Task.sleep(nanoseconds: 16_666_666)

                    // 步骤3：分段滚动 - 先跳到接近位置
                    let targetIndex = monthSections.count - 1
                    let intermediateIndex = max(targetIndex - 3, 0)
                    proxy.scrollTo(intermediateIndex, anchor: .top)

                    // 步骤4：等待中间位置渲染
                    try? await Task.sleep(nanoseconds: 33_333_333) // ~33ms

                    // 步骤5：精确定位到底部
                    proxy.scrollTo(targetIndex, anchor: .bottom)
                }
                .onChange(of: viewModel.scrollToTodayTrigger) {
                    // 点击"今天"按钮：滚动到今天所在月
                    withAnimation {
                        proxy.scrollTo(todayMonthIndex, anchor: .center)
                    }
                }
            }

            // 星期标题（固定在顶部，覆盖在滚动区域上）
            VStack(spacing: 0) {
                HStack(spacing: geometry.size.width * 0.01) {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: geometry.size.height * 0.0141, weight: .medium))
                            .foregroundColor(Color(red: 90/255.0, green: 87/255.0, blue: 86/255.0))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.03)
                .padding(.top, max(geometry.safeAreaInsets.top - 10, 10))  // 安全区域 - 10pt，最小10pt
                .padding(.bottom, geometry.size.height * 0.0075)
                .background(topBackgroundColor)

                Spacer()
            }
        }
    }

    // 检测月份是否在可见范围内
    private func isMonthVisible(itemGeometry: GeometryProxy, in containerGeometry: GeometryProxy, monthIndex: Int) -> Bool {
        let itemFrame = itemGeometry.frame(in: .global)
        let containerFrame = containerGeometry.frame(in: .global)

        // 检查 item 是否与容器有交集
        return itemFrame.maxY > containerFrame.minY && itemFrame.minY < containerFrame.maxY
    }
}
