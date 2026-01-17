import SwiftUI

/// 年视图日历内容
struct YearCalendarContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    var topBackgroundColor: Color = Color.pageBackground
    var onSelectMonth: (MonthSection) -> Void = { _ in }

    @State private var monthSections: [MonthSection] = []
    @State private var didAutoScrollToCurrentYear = false
    @State private var hasScrolledToCurrentYear = false

    private var yearSections: [YearSection] {
        let grouped = Dictionary(grouping: monthSections, by: { $0.year })
        return grouped.keys.sorted().map { year in
            let months = grouped[year]?.sorted { $0.month < $1.month } ?? []
            return YearSection(year: year, months: months)
        }
    }

    var body: some View {
        Group {
            if monthSections.isEmpty {
                CalendarEmptyState(viewModel: viewModel, geometry: geometry)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        let horizontalPadding = geometry.size.width * 0.05
                        let monthSpacing = geometry.size.width * 0.04
                        let monthWidth = (geometry.size.width - horizontalPadding * 2 - monthSpacing * 2) / 3

                        LazyVStack(spacing: geometry.size.height * 0.03) {
                            ForEach(yearSections) { section in
                                YearSectionView(
                                    section: section,
                                    viewModel: viewModel,
                                    geometry: geometry,
                                    monthWidth: monthWidth,
                                    monthSpacing: monthSpacing,
                                    onSelectMonth: onSelectMonth
                                )
                                .id(section.year)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, geometry.size.height * 0.02)
                        .background(topBackgroundColor)
                    }
                    .background(topBackgroundColor)
                    .opacity(hasScrolledToCurrentYear ? 1 : 0)
                    .onAppear {
                        scrollToCurrentYear(using: proxy)
                    }
                }
            }
        }
        .onAppear {
            hasScrolledToCurrentYear = false
            didAutoScrollToCurrentYear = false
            loadInitialMonths()
        }
        .onChange(of: viewModel.periodRecords) { _, _ in
            loadInitialMonths()
        }
    }

    private func scrollToCurrentYear(using proxy: ScrollViewProxy) {
        let currentYear = Calendar.current.component(.year, from: Date())
        DispatchQueue.main.async {
            guard !didAutoScrollToCurrentYear else { return }
            didAutoScrollToCurrentYear = true
            proxy.scrollTo(currentYear, anchor: .top)
            DispatchQueue.main.async {
                hasScrolledToCurrentYear = true
            }
        }
    }

    private func loadInitialMonths() {
        guard let range = recordedMonthRange() else {
            monthSections = []
            return
        }
        monthSections = MonthSection.generateMonthSections(from: range.start, to: range.end)
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

private struct YearSection: Identifiable {
    let year: Int
    let months: [MonthSection]
    var id: Int { year }
}

private struct YearSectionView: View {
    let section: YearSection
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let monthWidth: CGFloat
    let monthSpacing: CGFloat
    let onSelectMonth: (MonthSection) -> Void

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: monthSpacing), count: 3)
    }

    var body: some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Text("\(section.year)")
                .font(.pingFang(size: geometry.size.height * 0.028, weight: .medium))
                .foregroundColor(Color("Hex111827"))

            LazyVGrid(columns: columns, spacing: geometry.size.height * 0.02) {
                ForEach(section.months) { month in
                    YearMonthView(
                        monthSection: month,
                        viewModel: viewModel,
                        geometry: geometry,
                        monthWidth: monthWidth,
                        onSelectMonth: onSelectMonth
                    )
                }
            }
        }
    }
}

private struct YearMonthView: View {
    let monthSection: MonthSection
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let monthWidth: CGFloat
    let onSelectMonth: (MonthSection) -> Void

    private var daySpacing: CGFloat {
        monthWidth * 0.02
    }

    private var dayCellSize: CGFloat {
        (monthWidth - daySpacing * 6) / 7
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(dayCellSize), spacing: daySpacing), count: 7)
    }

    var body: some View {
        VStack(spacing: geometry.size.height * 0.006) {
            Text("\(monthSection.month)月")
                .font(.pingFang(size: geometry.size.height * 0.015, weight: .medium))
                .foregroundColor(Color("Hex111827"))

            LazyVGrid(columns: columns, spacing: daySpacing) {
                ForEach(0..<monthSection.leadingBlankCount, id: \.self) { _ in
                    Color.clear
                        .frame(width: dayCellSize, height: dayCellSize)
                }

                ForEach(monthSection.days, id: \.self) { date in
                    YearCalendarDayCell(
                        viewModel: viewModel,
                        date: date,
                        geometry: geometry,
                        cellSize: dayCellSize
                    )
                }
            }
            .frame(width: monthWidth)
        }
        .frame(width: monthWidth)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectMonth(monthSection)
        }
    }
}

private struct YearCalendarDayCell: View {
    @ObservedObject var viewModel: PeriodViewModel
    let date: Date
    let geometry: GeometryProxy
    let cellSize: CGFloat

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var smallCircleSize: CGFloat {
        cellSize * 0.8
    }

    private var dateFontSize: CGFloat {
        cellSize * 0.58
    }

    private var todayDotSize: CGFloat {
        max(cellSize * 0.18, 1)
    }

    private var dotRadius: CGFloat {
        max(cellSize * 0.08, 1)
    }

    var body: some View {
        let showPeriodBackground = viewModel.shouldShowPeriodBackground(date)
        let showPredictionBorder = viewModel.shouldShowPredictionBorder(date)

        ZStack {
            if showPeriodBackground {
                Circle()
                    .fill(Color("HexFF87A5"))
                    .blur(radius: geometry.size.height * 0.0003)
                    .frame(width: smallCircleSize, height: smallCircleSize)
            } else if showPredictionBorder {
                DottedCircle(dotCount: 12, dotRadius: dotRadius)
                    .foregroundColor(Color("HexFF9BB1"))
                    .frame(width: smallCircleSize, height: smallCircleSize)
            }

            VStack(spacing: cellSize * 0.08) {
                Text(date.shortDateString)
                    .font(.pingFang(size: dateFontSize, weight: isToday ? .semibold : .regular))
                    .foregroundColor(showPeriodBackground ? Color("HexFEFFFF") : Color("Hex111827"))

                if isToday {
                    Circle()
                        .fill(showPeriodBackground ? Color("HexFEFFFF") : Color("HexB4B4B4"))
                        .frame(width: todayDotSize, height: todayDotSize)
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
    }
}
