import Combine
import Foundation

class PeriodViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var currentWeekDates: [Date] = []

    // MARK: - 日期选择器状态
    @Published var showDatePicker: Bool = false
    @Published var tempSelectedDates: Set<Date> = []  // 临时选中的日期集合
    @Published var scrollToTodayTrigger: Bool = false  // 滚动到今天触发器
    @Published var isTodayVisible: Bool = true  // 今天是否在可见范围内

    // MARK: - 月经记录
    @Published var currentPeriodRecord: PeriodRecord? = nil  // 最新一次记录
    @Published var periodRecords: [PeriodRecord] = []        // 历史记录

    // MARK: - 性能优化缓存
    private var cachedRecordedDates: Set<TimeInterval> = []  // 缓存所有记录日期的时间戳

    // MARK: - 配置参数
    private let defaultPredictionDays: Int = 6
    private let minGapToNextPeriod: Int = 10
    private let minGapFromLastPeriod: Int = 6

    // MARK: - 日期监听
    private var dateCheckTimer: Timer?

    init() {
        let today = Date().startOfDay()
        self.selectedDate = today
        updateWeekDates(for: today)
        loadRecords()
        startDateMonitoring()
    }

    deinit {
        dateCheckTimer?.invalidate()
    }

    // 监听日期变化
    private func startDateMonitoring() {
        // 每60秒检查一次日期是否变化
        dateCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let today = Date().startOfDay()

            // 如果当前选中的日期不是今天，自动更新到今天
            if !self.selectedDate.isSameDay(as: today) {
                self.selectedDate = today
                self.updateWeekDates(for: today)
            }
        }
    }

    // MARK: - Week Navigation

    func updateWeekDates(for date: Date) {
        let weekStart = date.getWeekStart()
        currentWeekDates = (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    func moveToNextWeek() {
        selectedDate = selectedDate.adding(days: 7)
        updateWeekDates(for: selectedDate)
    }

    func moveToPreviousWeek() {
        selectedDate = selectedDate.adding(days: -7)
        updateWeekDates(for: selectedDate)
    }

    // MARK: - Date Selection

    func selectDate(_ date: Date) {
        selectedDate = date.startOfDay()
    }

    // MARK: - Computed Properties

    var displayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }

    var currentPeriodDay: Int? {
        return nil
    }

    // 判断今天是否在月经期内（用于首页周历日期显示）
    var isTodayInPeriod: Bool {
        let today = Date().startOfDay()
        return shouldShowPeriodBackground(today)
    }

    // 判断选中日期是否在月经期内（用于背景色显示，包括未来预测日期）
    var isSelectedDateInPeriodForBackground: Bool {
        let targetDate = selectedDate.startOfDay()
        // 使用缓存进行 O(1) 查询，包括未来的预测日期
        return cachedRecordedDates.contains(targetDate.timeIntervalSince1970)
    }

    // 判断选中日期是否在月经期内（含预测的未来经期）
    var isSelectedDateInPeriod: Bool {
        let targetDate = selectedDate.startOfDay()
        return cachedRecordedDates.contains(targetDate.timeIntervalSince1970)
    }

    // MARK: - 选中日期状态

    /// 获取选中日期的状态
    var selectedDateStatus: SelectedDateStatus {
        return getDateStatus(for: selectedDate)
    }

    /// 获取指定日期的状态
    func getDateStatus(for date: Date) -> SelectedDateStatus {
        let targetDate = date.startOfDay()

        // 边界情况：无任何记录
        guard !periodRecords.isEmpty else {
            return .beforeAllPeriods
        }

        // 检查是否在任何经期内（使用缓存 O(1) 查询）
        if cachedRecordedDates.contains(targetDate.timeIntervalSince1970) {
            // 找到包含该日期的经期记录
            if let record = periodRecords.first(where: { $0.contains(targetDate) }),
               let startDate = record.startDate {
                // 计算是第几天（从1开始）
                let dayNumber = targetDate.daysSince(startDate) + 1
                return .inPeriod(dayNumber: dayNumber)
            }
        }

        // 不在经期内，判断是否在所有经期之前
        if let firstPeriodStart = periodRecords.first?.startDate,
           targetDate < firstPeriodStart {
            return .beforeAllPeriods
        }

        // 在经期之后，找到最近的上一个经期
        let previousPeriods = periodRecords.filter {
            guard let endDate = $0.endDate else { return false }
            return endDate < targetDate
        }

        if let lastPreviousPeriod = previousPeriods.last,
           let lastPeriodStart = lastPreviousPeriod.startDate {
            let daysSince = targetDate.daysSince(lastPeriodStart) + 1
            return .afterPeriod(daysSinceLastPeriodStart: daysSince)
        }

        // 兜底：在第一个经期之前
        return .beforeAllPeriods
    }

    // MARK: - 日期选择器控制

    func openDatePicker() {
        showDatePicker = true
        // 数据加载延迟到视图呈现后，避免阻塞弹窗动画
    }

    /// 加载日期选择器数据（在视图呈现后调用）
    func loadDatePickerData() {
        tempSelectedDates = getAllRecordedDates()
    }

    func closeDatePicker() {
        showDatePicker = false
        tempSelectedDates = []
    }

    /// 滚动到今天
    func scrollToToday() {
        scrollToTodayTrigger.toggle()
    }

    // MARK: - 多选逻辑

    /// 获取所有已记录的日期（优化版）
    private func getAllRecordedDates() -> Set<Date> {
        return periodRecords.reduce(into: Set<Date>()) { result, record in
            record.dates.forEach { result.insert($0.startOfDay()) }
        }
    }

    /// 处理日期点击
    func handleDateTap(_ date: Date) {
        let targetDate = date.startOfDay()
        let today = Date().startOfDay()
        let extendableDates = getExtendableDates()

        if tempSelectedDates.contains(targetDate) {
            // 已选中 → 反选（取消）
            tempSelectedDates.remove(targetDate)

            if targetDate.isSameDay(as: today) {
                // 取消今天 → 删除所有未来日期
                removeFutureDates()
            } else if targetDate > today {
                // 取消未来日期 → 删除该日期之后的所有日期
                removeFutureDatesAfter(targetDate)
            }
            // 取消过去日期 → 不做级联删除
        } else if extendableDates.contains(targetDate) {
            // 可扩展日期 → 直接选中（不触发预测）
            tempSelectedDates.insert(targetDate)
        } else {
            // 普通未选中日期 → 检查是否触发预测
            if shouldAutoPredict(for: targetDate) {
                // 选中6天
                for i in 0..<defaultPredictionDays {
                    tempSelectedDates.insert(targetDate.adding(days: i))
                }
            } else {
                // 只选中当前日期
                tempSelectedDates.insert(targetDate)
            }
        }
    }

    /// 移除所有未来日期的选中状态
    private func removeFutureDates() {
        let today = Date().startOfDay()
        tempSelectedDates = tempSelectedDates.filter { $0 <= today }
    }

    /// 移除某个日期之后的所有已选日期
    private func removeFutureDatesAfter(_ date: Date) {
        tempSelectedDates = tempSelectedDates.filter { $0 <= date }
    }

    /// 检查是否满足自动预测条件
    func shouldAutoPredict(for date: Date) -> Bool {
        let targetDate = date.startOfDay()

        // 条件 A：与下一次经期的距离
        let conditionA = checkConditionA(for: targetDate)

        // 条件 B：与上一次经期的距离
        let conditionB = checkConditionB(for: targetDate)

        return conditionA && conditionB
    }

    /// 条件 A：检查与下一次经期的距离
    /// - 有下一次经期：当前日期 -> 下次开始 >= 10天
    /// - 无下一次经期：成立
    private func checkConditionA(for date: Date) -> Bool {
        // 从当前选中日期构建临时经期列表
        let existingPeriods = buildPeriodsFromSelectedDates()

        // 找到在 date 之后最近的经期开始日
        let nextPeriodStart = existingPeriods
            .compactMap { $0.startDate }
            .filter { $0 > date }
            .min()

        guard let nextStart = nextPeriodStart else {
            return true // 无下一次经期
        }

        let gap = nextStart.daysSince(date)
        return gap >= minGapToNextPeriod
    }

    /// 条件 B：检查与上一次经期的距离
    /// - 有上一次经期：上次结束 -> 当前日期 >= 6天
    /// - 无上一次经期：成立
    private func checkConditionB(for date: Date) -> Bool {
        // 从当前选中日期构建临时经期列表
        let existingPeriods = buildPeriodsFromSelectedDates()

        // 找到在 date 之前最近的经期结束日
        let prevPeriodEnd = existingPeriods
            .compactMap { $0.endDate }
            .filter { $0 < date }
            .max()

        guard let prevEnd = prevPeriodEnd else {
            return true // 无上一次经期
        }

        let gap = date.daysSince(prevEnd)
        return gap >= minGapFromLastPeriod
    }

    /// 获取所有可扩展日期（每个连续经期段的下一天）
    func getExtendableDates() -> Set<Date> {
        let periods = buildPeriodsFromSelectedDates()
        var extendableDates: Set<Date> = []

        for period in periods {
            if let endDate = period.endDate {
                // 经期最后一天的下一天是可扩展日期
                extendableDates.insert(endDate.adding(days: 1))
            }
        }

        return extendableDates
    }

    /// 从选中日期集合构建经期记录列表
    /// 将连续的日期合并为一个经期记录
    func buildPeriodsFromSelectedDates() -> [PeriodRecord] {
        guard !tempSelectedDates.isEmpty else { return [] }

        // 排序所有选中日期
        let sortedDates = tempSelectedDates.sorted()

        var periods: [PeriodRecord] = []
        var currentPeriodDates: Set<Date> = []
        var lastDate: Date?

        for date in sortedDates {
            if let last = lastDate {
                let gap = date.daysSince(last)
                if gap == 1 {
                    // 连续日期，加入当前经期
                    currentPeriodDates.insert(date)
                } else {
                    // 不连续，保存当前经期，开始新经期
                    if !currentPeriodDates.isEmpty {
                        periods.append(PeriodRecord(dates: currentPeriodDates))
                    }
                    currentPeriodDates = [date]
                }
            } else {
                // 第一个日期
                currentPeriodDates.insert(date)
            }
            lastDate = date
        }

        // 保存最后一个经期
        if !currentPeriodDates.isEmpty {
            periods.append(PeriodRecord(dates: currentPeriodDates))
        }

        return periods.sorted { ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast) }
    }

    // MARK: - 日期选择器日期状态

    func getStateForDatePicker(_ date: Date) -> DateState {
        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 检查是否选中
        if tempSelectedDates.contains(dateToCheck) {
            return .selected
        }

        // 检查是否是可扩展日期
        let extendableDates = getExtendableDates()
        if extendableDates.contains(dateToCheck) {
            // 只有未来日期的可扩展才显示虚线样式
            if dateToCheck > today {
                return .extendable
            }
            // 历史日期（含今天）的可扩展日期显示为普通样式
            return .normal
        }

        // 远期未来日期禁用（超过可扩展日期范围）
        if dateToCheck > today {
            return .disabled
        }

        return .normal
    }

    // MARK: - 保存记录

    func savePeriodRecords() {
        // 从散点日期构建经期记录
        periodRecords = buildPeriodsFromSelectedDates()

        // 更新当前记录（最新的一条）
        currentPeriodRecord = periodRecords.last

        // 更新缓存
        updateCachedDates()

        // 持久化
        saveRecords()

        // 关闭日期选择器
        showDatePicker = false
        tempSelectedDates = []
    }

    // MARK: - 首页日期背景圈状态

    /// 更新缓存：将所有记录的日期提取为时间戳集合
    private func updateCachedDates() {
        cachedRecordedDates = periodRecords.reduce(into: Set<TimeInterval>()) { result, record in
            // 直接使用 dateIntervals，避免调用 dates 计算属性
            result.formUnion(record.dateIntervals)
        }
    }

    func shouldShowPeriodBackground(_ date: Date) -> Bool {
        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 只在今天及之前的日期显示实心圆（实际记录）
        guard dateToCheck <= today else { return false }

        // 使用缓存进行 O(1) 查询
        return cachedRecordedDates.contains(dateToCheck.timeIntervalSince1970)
    }

    func shouldShowPredictionBorder(_ date: Date) -> Bool {
        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 只在今天之后的日期显示虚线框（预测日期）
        guard dateToCheck > today else { return false }

        // 使用缓存进行 O(1) 查询
        return cachedRecordedDates.contains(dateToCheck.timeIntervalSince1970)
    }

    // MARK: - Date State Query

    func getStateForDate(_ date: Date) -> DateState {
        let calendar = Calendar.current
        let dateToCheck = date.startOfDay()
        let selectedToCheck = selectedDate.startOfDay()
        let isSelected = calendar.isDate(dateToCheck, inSameDayAs: selectedToCheck)

        if isSelected {
            return .selected
        }

        return .normal
    }

    /// 获取指定日期在其所属经期中是第几天
    /// - Parameter date: 要查询的日期
    /// - Returns: 如果日期在经期内，返回天数（1-based）；否则返回nil
    func getDayNumberInPeriod(_ date: Date) -> Int? {
        let dateToCheck = date.startOfDay()

        // 从所有经期记录中查找包含此日期的记录
        for record in periodRecords {
            if record.contains(dateToCheck) {
                // 找到所属经期，获取已排序的日期列表
                let sortedDates = record.dates  // dates 已经是排序好的
                // 计算是第几天（从1开始）
                if let index = sortedDates.firstIndex(where: {
                    Calendar.current.isDate($0, inSameDayAs: dateToCheck)
                }) {
                    return index + 1  // 返回1-based的天数
                }
            }
        }

        return nil
    }

    // MARK: - 数据持久化

    private let legacyRecordsKey = "periodRecords"
    private let recordsKey = "periodRecords_v2"

    func loadRecords() {
        // 先尝试迁移旧数据
        migrateDataIfNeeded()

        // 加载新格式数据
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let records = try? JSONDecoder().decode([PeriodRecord].self, from: data) {
            self.periodRecords = records
            self.currentPeriodRecord = records.last
            // 更新缓存
            updateCachedDates()
        }
    }

    func saveRecords() {
        if let data = try? JSONEncoder().encode(periodRecords) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    /// 数据迁移：从旧格式迁移到新格式
    private func migrateDataIfNeeded() {
        // 检查是否已迁移
        if UserDefaults.standard.data(forKey: recordsKey) != nil {
            return // 已迁移
        }

        // 尝试读取旧数据并迁移
        if let legacyData = UserDefaults.standard.data(forKey: legacyRecordsKey),
           let legacyRecords = try? JSONDecoder().decode([LegacyPeriodRecord].self, from: legacyData) {
            let newRecords = legacyRecords.map { $0.toNewFormat() }
            if let newData = try? JSONEncoder().encode(newRecords) {
                UserDefaults.standard.set(newData, forKey: recordsKey)
            }
        }
    }

    // MARK: - 周期统计计算

    /// 获取所有已完成的周期
    var completedCycles: [CycleData] {
        guard periodRecords.count >= 2 else { return [] }

        var cycles: [CycleData] = []

        for i in 0..<(periodRecords.count - 1) {
            let currentPeriod = periodRecords[i]
            let nextPeriod = periodRecords[i + 1]

            guard let currentStart = currentPeriod.startDate,
                  let currentEnd = currentPeriod.endDate,
                  let nextStart = nextPeriod.startDate else { continue }

            let cycleDays = nextStart.daysSince(currentStart)

            cycles.append(CycleData(
                periodStartDate: currentStart,
                periodEndDate: currentEnd,
                nextPeriodStartDate: nextStart,
                cycleDays: cycleDays,
                periodDays: currentPeriod.duration
            ))
        }

        return cycles
    }

    /// 当前进行中的周期
    var currentCycle: CurrentCycleData? {
        guard let latestPeriod = periodRecords.last,
              let periodStart = latestPeriod.startDate,
              let periodEnd = latestPeriod.endDate else { return nil }

        let today = Date().startOfDay()
        let cycleStartDate = periodStart
        let elapsedDays = today.daysSince(cycleStartDate) + 1
        let predictedTotalDays = averageCycleDays ?? 28
        let predictedEndDate = cycleStartDate.adding(days: predictedTotalDays - 1)

        return CurrentCycleData(
            cycleStartDate: cycleStartDate,
            periodStartDate: periodStart,
            periodEndDate: periodEnd,
            elapsedDays: elapsedDays,
            predictedTotalDays: predictedTotalDays,
            predictedEndDate: predictedEndDate,
            periodDays: latestPeriod.duration
        )
    }

    /// 平均周期天数
    var averageCycleDays: Int? {
        let cycles = completedCycles
        guard !cycles.isEmpty else { return nil }

        let total = cycles.reduce(0) { $0 + $1.cycleDays }
        return total / cycles.count
    }

    /// 最长周期天数
    var maxCycleDays: Int {
        var allCycleDays: [Int] = completedCycles.map { $0.cycleDays }

        if let current = currentCycle {
            allCycleDays.append(current.elapsedDays)
        }

        return allCycleDays.max() ?? 28
    }
}
