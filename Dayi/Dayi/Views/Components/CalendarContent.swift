import SwiftUI

/// 日历页内容区域
struct CalendarContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    var topBackgroundColor: Color = Color.pageBackground
    var targetMonthId: String? = nil
    var onReachedTargetMonth: () -> Void = {}

    // 防止自动滚动重复触发
    @State private var didAutoScrollToBottom = false

    // 控制日历内容可见性（防止打开时闪动）
    @State private var hasScrolledToBottom = false

    @State private var monthSections: [MonthSection] = []
    @State private var isLoadingPastMonths = false
    @State private var hasReachedStartLimit = false
    @State private var didScrollToTargetMonth = false

    var body: some View {
        ZStack(alignment: .top) {
            if monthSections.isEmpty {
                CalendarEmptyState(viewModel: viewModel, geometry: geometry)
            } else {
                // 日历滚动区域（全屏）
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // 顶部占位空间（为星期标题留空）
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
                                    CalendarMonthGridView(
                                        monthSection: section,
                                        viewModel: viewModel,
                                        geometry: geometry
                                    )
                                }
                                .id(section.id)
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
                    .opacity(hasScrolledToBottom ? 1 : 0)
                    .onAppear {
                        scrollToInitialPosition(using: proxy)
                    }
                    .onChange(of: targetMonthId) { _, newValue in
                        guard newValue != nil else { return }
                        didScrollToTargetMonth = false
                        scrollToTargetMonth(using: proxy)
                    }
                    .onChange(of: monthSections) { _, _ in
                        scrollToTargetMonth(using: proxy)
                    }
                }
            }

            if !monthSections.isEmpty {
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
        .onAppear {
            hasScrolledToBottom = false
            didAutoScrollToBottom = false
            didScrollToTargetMonth = false
            loadInitialMonths()
        }
        .onChange(of: viewModel.periodRecords) { _, _ in
            loadInitialMonths()
        }
    }

    private func loadInitialMonths() {
        guard let range = recordedMonthRange() else {
            monthSections = []
            hasReachedStartLimit = true
            return
        }

        monthSections = MonthSection.generateMonthSections(from: range.start, to: range.end)
        hasReachedStartLimit = true
    }

    private func scrollToInitialPosition(using proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            guard !didAutoScrollToBottom else { return }
            didAutoScrollToBottom = true

            if targetMonthId != nil {
                scrollToTargetMonth(using: proxy)
            } else {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }

            DispatchQueue.main.async {
                hasScrolledToBottom = true
            }
        }
    }

    private func scrollToTargetMonth(using proxy: ScrollViewProxy) {
        guard let targetId = targetMonthId, !didScrollToTargetMonth else { return }
        guard monthSections.contains(where: { $0.id == targetId }) else { return }
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(targetId, anchor: .top)
            }
            didScrollToTargetMonth = true
            hasScrolledToBottom = true
            onReachedTargetMonth()
        }
    }

    private func loadPreviousMonths(using proxy: ScrollViewProxy) {
        guard hasScrolledToBottom else { return }
        guard !isLoadingPastMonths, !hasReachedStartLimit else { return }
        guard let firstSection = monthSections.first else { return }
        guard let minStartDate = recordedMonthRange()?.start else {
            hasReachedStartLimit = true
            return
        }

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
            .filter { hasPeriodInMonth($0) }
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

    private func hasPeriodInMonth(_ section: MonthSection) -> Bool {
        section.days.contains { date in
            viewModel.shouldShowPeriodBackground(date) || viewModel.shouldShowPredictionBorder(date)
        }
    }

    private func recordedMonthRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        guard let earliest = viewModel.periodRecords.compactMap({ $0.startDate }).min(),
              let latest = viewModel.periodRecords.compactMap({ $0.endDate }).max() else {
            return nil
        }

        guard let startOfFirstMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: earliest)),
              let startOfLastMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: latest)),
              let dayRange = calendar.range(of: .day, in: .month, for: startOfLastMonth) else {
            return nil
        }

        let endOfLastMonth = calendar.date(byAdding: .day, value: dayRange.count - 1, to: startOfLastMonth) ?? latest
        return (startOfFirstMonth.startOfDay(), endOfLastMonth.startOfDay())
    }
}

/// 日历页单月日期网格
struct CalendarMonthGridView: View {
    let monthSection: MonthSection
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var cellWidth: CGFloat {
        geometry.size.width * 0.12
    }

    private var cellHeight: CGFloat {
        geometry.size.height * 0.09
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: geometry.size.height * 0.01) {
            // 前置空白占位（对齐星期列）
            ForEach(0..<monthSection.leadingBlankCount, id: \.self) { _ in
                Color.clear
                    .frame(width: cellWidth, height: cellHeight)
            }

            // 该月所有日期
            ForEach(monthSection.days, id: \.self) { date in
                CalendarDayCell(
                    viewModel: viewModel,
                    date: date,
                    geometry: geometry
                )
            }
        }
        .padding(.horizontal, geometry.size.width * 0.03)
    }
}

/// 日历页单个日期单元格
struct CalendarDayCell: View {
    @ObservedObject var viewModel: PeriodViewModel
    let date: Date
    let geometry: GeometryProxy

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var cellWidth: CGFloat {
        geometry.size.width * 0.12
    }

    private var cellHeight: CGFloat {
        geometry.size.height * 0.09
    }

    private var smallCircleSize: CGFloat {
        cellWidth * 0.75
    }

    private var fontWeight: Font.Weight {
        isToday ? .semibold : .regular
    }

    var body: some View {
        let showPeriodBackground = viewModel.shouldShowPeriodBackground(date)
        let showPredictionBorder = viewModel.shouldShowPredictionBorder(date)

        ZStack {
            if showPeriodBackground {
                // 经期背景圆
                Circle()
                    .fill(Color("HexFF87A5"))
                    .blur(radius: geometry.size.height * 0.0003)
                    .frame(width: smallCircleSize, height: smallCircleSize)
            } else if showPredictionBorder {
                // 预测经期虚线圆边框
                DottedCircle(dotCount: 18, dotRadius: 1.5)
                    .foregroundColor(Color("HexFF9BB1"))
                    .frame(width: smallCircleSize, height: smallCircleSize)
            }

            VStack(spacing: geometry.size.height * 0.0023) {
                Text(date.shortDateString)
                    .font(.pingFang(size: geometry.size.height * 0.0229, weight: fontWeight))
                    .foregroundColor(showPeriodBackground ? Color("HexFEFFFF") : Color("Hex111827"))

                if isToday {
                    Circle()
                        .fill(showPeriodBackground ? Color("HexFEFFFF") : Color("HexB4B4B4"))
                        .frame(
                            width: geometry.size.height * 0.0047,
                            height: geometry.size.height * 0.0047
                        )
                }
            }
        }
        .frame(width: cellWidth, height: cellHeight)
    }
}
