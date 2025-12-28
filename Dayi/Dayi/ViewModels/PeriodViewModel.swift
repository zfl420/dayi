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

    // MARK: - 日期选择器控制

    func openDatePicker() {
        showDatePicker = true
        // 加载所有历史记录的日期到选中集合
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

    /// 获取所有已记录的日期
    private func getAllRecordedDates() -> Set<Date> {
        var allDates: Set<Date> = []
        for record in periodRecords {
            for date in record.dates {
                allDates.insert(date.startOfDay())
            }
        }
        return allDates
    }

    /// 处理日期点击
    func handleDateTap(_ date: Date) {
        let targetDate = date.startOfDay()
        let today = Date().startOfDay()
        let extendableDates = getExtendableDates()

        if tempSelectedDates.contains(targetDate) {
            // 已选中 → 反选（取消）
            tempSelectedDates.remove(targetDate)

            // 如果取消的是今天，则同时取消所有未来日期
            if targetDate.isSameDay(as: today) {
                removeFutureDates()
            }
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

        // 持久化
        saveRecords()

        // 关闭日期选择器
        showDatePicker = false
        tempSelectedDates = []
    }

    // MARK: - 首页日期背景圈状态

    func shouldShowPeriodBackground(_ date: Date) -> Bool {
        guard let record = currentPeriodRecord else { return false }

        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 只在今天及之前的日期显示实心圆（实际记录）
        guard dateToCheck <= today else { return false }

        return record.contains(dateToCheck)
    }

    func shouldShowPredictionBorder(_ date: Date) -> Bool {
        guard let record = currentPeriodRecord else { return false }

        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 只在今天之后的日期显示虚线框（预测日期）
        guard dateToCheck > today else { return false }

        return record.contains(dateToCheck)
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
}
