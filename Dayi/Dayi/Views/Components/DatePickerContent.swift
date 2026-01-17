import SwiftUI

/// 用于检测视图可见性的 PreferenceKey（使用 String ID 而非索引）
struct VisibleMonthPreferenceKey: PreferenceKey {
    static var defaultValue: Set<String> = []

    static func reduce(value: inout Set<String>, nextValue: () -> Set<String>) {
        value.formUnion(nextValue())
    }
}

/// 日期选择器内容区域
struct DatePickerContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    var topBackgroundColor: Color = Color.pageBackground

    // 防止自动滚动重复触发
    @State private var didAutoScrollToBottom = false

    // 控制日历内容可见性（防止打开时闪动）
    @State private var hasScrolledToBottom = false

    // 今天是否可见（本地状态，不写回 ObservedObject 避免触发重绘）
    @State private var isTodayVisibleLocal: Bool = true

    @State private var monthSections: [MonthSection] = []
    @State private var isLoadingPastMonths = false
    @State private var hasReachedStartLimit = false

    // 日期范围：今天往前 60 个月（5 年历史）+ 往后 14 天（两周）
    private var startDate: Date {
        let today = Date().startOfDay()
        let calendar = Calendar.current
        // 往前 60 个月
        return calendar.date(byAdding: .month, value: -60, to: today) ?? today
    }

    private var futureEndDate: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // weekday: 1=周日, 2=周一, ..., 7=周六
        let weekday = calendar.component(.weekday, from: today)

        // 距离"本周周日"的天数：周日->0，周一->6，周六->1
        let daysUntilSunday = (8 - weekday) % 7

        // 本周周日（当天若是周日则就是 today）
        let endOfThisWeek = calendar.date(byAdding: .day, value: daysUntilSunday, to: today) ?? today

        // 再往后 2 周（14 天），仍然是周日
        let finalEndDate = calendar.date(byAdding: .day, value: 14, to: endOfThisWeek) ?? endOfThisWeek

        // ✅ 调试打印：验证最后一天是周日
        #if DEBUG
        let finalWeekday = calendar.component(.weekday, from: finalEndDate)
        print("📅 [futureEndDate] today: \(DateFormatters.debugYmdWeek.string(from: today))")
        print("📅 [futureEndDate] endOfThisWeek: \(DateFormatters.debugYmdWeek.string(from: endOfThisWeek))")
        print("📅 [futureEndDate] futureEndDate: \(DateFormatters.debugYmdWeek.string(from: finalEndDate)), weekday=\(finalWeekday) (1=周日)")
        assert(finalWeekday == 1, "❌ futureEndDate 必须是周日！")
        #endif

        return finalEndDate
    }

    private var minStartDate: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 2000, month: 1, day: 1)
        return calendar.date(from: components)?.startOfDay() ?? Date.distantPast
    }

    // 今天所在月的 ID（稳定标识，不用 index）
    private var todayMonthId: String {
        let calendar = Calendar.current
        let today = Date().startOfDay()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        return "\(year)-\(month)"
    }

    private enum DateFormatters {
        static let debugYmdWeek: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd (E)"
            return formatter
        }()
    }


    var body: some View {
        ZStack(alignment: .top) {
            // 日历滚动区域（全屏）
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 顶部占位空间（为星期标题留空）
                        // 计算：星期标题高度 + 顶部边距 + 底部边距
                        Color.clear
                            .frame(height: geometry.size.height * 0.0366)

                        // 顶部加载触发器
                        Color.clear
                            .frame(height: 1)
                            .id("TOP")
                            .onAppear {
                                loadPreviousMonths(using: proxy)
                            }

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
                            .id(section.id)  // ✅ 使用 section.id 而非 index，防止滚动瞬移
                            // 检测今天所在月的可见性
                            .background(
                                GeometryReader { itemGeometry in
                                    Color.clear
                                        .preference(
                                            key: VisibleMonthPreferenceKey.self,
                                            value: isMonthVisible(itemGeometry: itemGeometry, in: geometry, sectionId: section.id) ? [section.id] : []
                                        )
                                }
                            )
                        }

                        // BOTTOM marker：用于稳定定位到底部
                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                    .background(topBackgroundColor)
                }
                .background(topBackgroundColor)
                .opacity(hasScrolledToBottom ? 1 : 0)  // ✅ 滚动完成前隐藏，防止闪动
                // ✅ 完全移除 onPreferenceChange，避免滚动时触发任何状态变化
                // "今天"按钮的显示逻辑改为始终显示，或在外层判断
                .onAppear {
                    // 每次打开都重置状态
                    hasScrolledToBottom = false
                    didAutoScrollToBottom = false

                    // 加载数据
                    viewModel.loadDatePickerData()
                    loadInitialMonths()

                    // 滚动到底部并在完成后显示内容
                    DispatchQueue.main.async {
                        guard !didAutoScrollToBottom else { return }
                        didAutoScrollToBottom = true

                        // 使用 BOTTOM marker 稳定定位到底部
                        proxy.scrollTo("BOTTOM", anchor: .bottom)

                        // 下一帧再显示内容，避免闪动
                        DispatchQueue.main.async {
                            hasScrolledToBottom = true
                        }
                    }
                }
                .onChange(of: viewModel.scrollToTodayTrigger) {
                    // 点击"今天"按钮：滚动到底部（BOTTOM marker）
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            // 星期标题（固定在顶部，覆盖在滚动区域上）
            VStack(spacing: 0) {
                HStack(spacing: geometry.size.width * 0.01) {
                    ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { label in
                        Text(label)
                            .font(.pingFang(size: geometry.size.height * 0.0141, weight: .medium))
                            .foregroundColor(Color("Hex6B7280"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.03)
                .padding(.top, geometry.size.height * 0.025)  // 星期标题顶部间距
                .padding(.bottom, geometry.size.height * 0.0075)
                .background(topBackgroundColor)

                Spacer()
            }
        }
    }

    // 检测月份是否在可见范围内（改为接收 sectionId）
    private func isMonthVisible(itemGeometry: GeometryProxy, in containerGeometry: GeometryProxy, sectionId: String) -> Bool {
        let itemFrame = itemGeometry.frame(in: .global)
        let containerFrame = containerGeometry.frame(in: .global)

        // 检查 item 是否与容器有交集
        return itemFrame.maxY > containerFrame.minY && itemFrame.minY < containerFrame.maxY
    }

    private func loadInitialMonths() {
        monthSections = MonthSection.generateMonthSections(from: startDate, to: futureEndDate)
        hasReachedStartLimit = startDate <= minStartDate
    }

    private func loadPreviousMonths(using proxy: ScrollViewProxy) {
        guard hasScrolledToBottom else { return }
        guard !isLoadingPastMonths, !hasReachedStartLimit else { return }
        guard let firstSection = monthSections.first else { return }

        let calendar = Calendar.current
        guard let firstMonthStart = calendar.date(from: DateComponents(year: firstSection.year, month: firstSection.month, day: 1)) else {
            return
        }

        isLoadingPastMonths = true

        let candidateStart = calendar.date(byAdding: .month, value: -12, to: firstMonthStart) ?? firstMonthStart
        let limitedStart = candidateStart < minStartDate ? minStartDate : candidateStart
        let endDate = calendar.date(byAdding: .day, value: -1, to: firstMonthStart) ?? firstMonthStart

        guard limitedStart <= endDate else {
            hasReachedStartLimit = true
            isLoadingPastMonths = false
            return
        }

        let prependSections = MonthSection.generateMonthSections(from: limitedStart, to: endDate)
        guard !prependSections.isEmpty else {
            hasReachedStartLimit = true
            isLoadingPastMonths = false
            return
        }

        let anchorId = firstSection.id
        monthSections.insert(contentsOf: prependSections, at: 0)

        DispatchQueue.main.async {
            proxy.scrollTo(anchorId, anchor: .top)
            isLoadingPastMonths = false
            if limitedStart <= minStartDate {
                hasReachedStartLimit = true
            }
        }
    }
}
