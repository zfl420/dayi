import Combine
import Foundation

class PeriodViewModel: ObservableObject {
    @Published var selectedDate: Date = Date().startOfDay()
    @Published var currentWeekDates: [Date] = []
    @Published var periodRecords: [PeriodRecord] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var showSettingsDrawer: Bool = false
    @Published var showRecordSheet: Bool = false
    @Published var showEditSheet: Bool = false

    private let dataManager: PeriodDataManager
    private let calculator: PeriodCalculator

    init(
        dataManager: PeriodDataManager = PeriodDataManager(),
        calculator: PeriodCalculator = PeriodCalculator()
    ) {
        self.dataManager = dataManager
        self.calculator = calculator
        loadData()
        updateWeekDates(for: selectedDate)
    }

    // MARK: - Data Loading

    func loadData() {
        periodRecords = dataManager.loadRecords()
        settings = dataManager.loadSettings()
    }

    func saveData() {
        dataManager.saveRecords(periodRecords)
        dataManager.saveSettings(settings)
    }

    // MARK: - Week Navigation

    func updateWeekDates(for date: Date) {
        currentWeekDates = calculator.getWeekDates(containing: date)
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

    // MARK: - Period Management

    func recordNewPeriod(startDate: Date) {
        let newRecord = PeriodRecord(startDate: startDate.startOfDay())
        periodRecords.append(newRecord)
        periodRecords.sort { $0.startDate < $1.startDate }

        // 更新平均周期
        if let avgCycle = calculator.calculateAverageCycle(from: periodRecords) {
            settings.averageCycleDays = avgCycle
        }

        saveData()
    }

    func updatePeriodEndDate(recordId: UUID, endDate: Date) {
        if let index = periodRecords.firstIndex(where: { $0.id == recordId }) {
            periodRecords[index].endDate = endDate.startOfDay()
            periodRecords[index].updatedAt = Date()
        }
        saveData()
    }

    func deletePeriod(recordId: UUID) {
        periodRecords.removeAll { $0.id == recordId }
        saveData()
    }

    // MARK: - Computed Properties

    var displayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }

    var isInPeriod: Bool {
        calculator.getCurrentPeriodInfo(on: selectedDate, records: periodRecords).isInPeriod
    }

    var currentPeriodDay: Int? {
        calculator.getCurrentPeriodInfo(on: selectedDate, records: periodRecords).dayNumber
    }

    var currentPeriodRecord: PeriodRecord? {
        calculator.getCurrentPeriodInfo(on: selectedDate, records: periodRecords).record
    }

    var actionButtonTitle: String {
        isInPeriod ? "编辑月经日期" : "记录月经"
    }

    var currentDateState: DateState {
        calculator.getDateState(
            for: selectedDate,
            selectedDate: selectedDate,
            records: periodRecords,
            settings: settings
        )
    }

    // MARK: - Date State Query

    func getStateForDate(_ date: Date) -> DateState {
        calculator.getDateState(
            for: date,
            selectedDate: selectedDate,
            records: periodRecords,
            settings: settings
        )
    }
}
