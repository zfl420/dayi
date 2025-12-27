import Combine
import Foundation

class PeriodViewModel: ObservableObject {
    @Published var selectedDate: Date = Date().startOfDay()
    @Published var currentWeekDates: [Date] = []

    init() {
        updateWeekDates(for: selectedDate)
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
}
