import Combine
import Foundation

class PeriodViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var currentWeekDates: [Date] = []

    // MARK: - 日期选择器状态
    @Published var showDatePicker: Bool = false
    @Published var tempSelectedDate: Date
    @Published var extraExtendedDays: Int = 0  // 额外扩展的天数（超过默认6天的部分）

    // MARK: - 月经记录
    @Published var currentPeriodRecord: PeriodRecord? = nil  // 最新一次记录
    @Published var periodRecords: [PeriodRecord] = []        // 历史记录

    // MARK: - 日期监听
    private var dateCheckTimer: Timer?

    init() {
        let today = Date().startOfDay()
        self.selectedDate = today
        self.tempSelectedDate = today
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

    // MARK: - 计算属性

    var lastPeriodEndDate: Date? {
        return currentPeriodRecord?.endDate
    }

    var datePickerMaxDate: Date {
        return Date().startOfDay()
    }

    var datePickerMinDate: Date {
        guard let endDate = lastPeriodEndDate else {
            // 1年前的日期（性能优化）
            return Calendar.current.date(byAdding: .year, value: -1, to: Date().startOfDay()) ?? Date().startOfDay().adding(days: -365)
        }
        return endDate.adding(days: 1)
    }

    // MARK: - 日期选择器控制

    func openDatePicker() {
        showDatePicker = true
        tempSelectedDate = selectedDate
    }

    func closeDatePicker() {
        showDatePicker = false
    }

    func savePeriodRecord() {
        let newRecord = PeriodRecord(startDate: tempSelectedDate)
        currentPeriodRecord = newRecord
        periodRecords.append(newRecord)
        selectedDate = tempSelectedDate
        showDatePicker = false
        saveRecords()
    }

    func resetToToday() {
        tempSelectedDate = Date().startOfDay()
    }

    func updateTempDate(_ date: Date) {
        tempSelectedDate = date.startOfDay()
        extraExtendedDays = 0  // 重置额外扩展天数
    }

    // MARK: - 日期选择器日期状态

    /// 默认经期天数
    private let defaultPeriodDays: Int = 6

    /// 总经期天数（默认 + 额外扩展）
    var totalPeriodDays: Int {
        return defaultPeriodDays + extraExtendedDays
    }

    /// 预测期是否包含今天之后的日期
    var predictionHasFutureDates: Bool {
        let today = Date().startOfDay()
        let lastPredictionDate = tempSelectedDate.adding(days: totalPeriodDays - 1)
        return lastPredictionDate > today
    }

    func getStateForDatePicker(_ date: Date) -> DateState {
        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()

        // 当前选中
        if dateToCheck.isSameDay(as: tempSelectedDate) {
            return .selected
        }

        let daysAfter = dateToCheck.daysSince(tempSelectedDate)

        // 在预测期范围内（选中日期后1到totalPeriodDays-1天）
        if daysAfter > 0 && daysAfter < totalPeriodDays {
            // 额外扩展的天数显示为 extended
            if daysAfter >= defaultPeriodDays {
                return .extended
            }
            return .afterPeriodDashed
        }

        // 可扩展日期：预测期最后一天的后一天
        if daysAfter == totalPeriodDays {
            // 根据日期是否在今天之后区分样式
            if dateToCheck > today {
                return .extendable       // 今天之后：灰色虚线框
            } else {
                return .extendablePast   // 今天及之前：灰色实线框
            }
        }

        // 不可选：早于上次经期结束日
        if dateToCheck < datePickerMinDate {
            return .disabled
        }

        // 今天之后且不在预测范围内的日期不显示
        if dateToCheck > today && daysAfter > totalPeriodDays {
            return .disabled
        }

        return .normal
    }

    /// 扩展一天经期
    func extendPeriodByOneDay() {
        extraExtendedDays += 1
    }

    // MARK: - 首页日期背景圈状态

    func shouldShowPeriodBackground(_ date: Date) -> Bool {
        guard let record = currentPeriodRecord else { return false }
        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()
        // 记录日期至今天：S ... today
        return dateToCheck >= record.startDate && dateToCheck <= today
    }

    func shouldShowPredictionBorder(_ date: Date) -> Bool {
        // 只有在有记录的情况下才显示预测虚线
        guard currentPeriodRecord != nil else { return false }

        let dateToCheck = date.startOfDay()
        let today = Date().startOfDay()
        // 今天至第七天：today ... today+6
        let daysSinceToday = dateToCheck.daysSince(today)
        return daysSinceToday >= 0 && daysSinceToday <= 6
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

    private let recordsKey = "periodRecords"

    func loadRecords() {
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
}
