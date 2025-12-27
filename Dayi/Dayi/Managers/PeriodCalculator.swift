import Foundation

class PeriodCalculator {

    // MARK: - 日期状态判断

    func getDateState(
        for date: Date,
        selectedDate: Date,
        records: [PeriodRecord],
        settings: AppSettings
    ) -> DateState {
        let calendar = Calendar.current
        let dateToCheck = date.startOfDay()
        let selectedToCheck = selectedDate.startOfDay()
        let isSelected = calendar.isDate(dateToCheck, inSameDayAs: selectedToCheck)

        // 1. 检查实际经期
        if let actualDay = isPeriodDay(dateToCheck, in: records) {
            return isSelected ? .actualAndSelected(day: actualDay) : .actualPeriod(day: actualDay)
        }

        // 2. 检查预测经期
        if settings.showPrediction && isPredictedPeriodDay(dateToCheck, records: records, settings: settings) {
            return isSelected ? .predictedAndSelected : .predictedPeriod
        }

        // 3. 仅选中状态
        if isSelected {
            return .selected
        }

        return .normal
    }

    // MARK: - 检查是否在经期中

    private func isPeriodDay(_ date: Date, in records: [PeriodRecord]) -> Int? {
        for record in records {
            let startDate = record.startDate.startOfDay()
            let endDate = (record.endDate ?? record.startDate).startOfDay()

            if date >= startDate && date <= endDate {
                let components = Calendar.current.dateComponents([.day], from: startDate, to: date)
                let dayNumber = (components.day ?? 0) + 1
                return dayNumber
            }
        }
        return nil
    }

    private func isPredictedPeriodDay(_ date: Date, records: [PeriodRecord], settings: AppSettings) -> Bool {
        let predictions = predictNextPeriods(from: records, settings: settings)
        for prediction in predictions {
            if date >= prediction.startDate.startOfDay() && date <= prediction.endDate.startOfDay() {
                return true
            }
        }
        return false
    }

    // MARK: - 预测经期

    func predictNextPeriods(from records: [PeriodRecord], settings: AppSettings) -> [PredictionPeriod] {
        guard let lastRecord = records.sorted(by: { $0.startDate > $1.startDate }).first else {
            return []
        }

        let averageCycle = calculateAverageCycle(from: records) ?? settings.averageCycleDays
        let periodDuration = settings.averagePeriodDays

        var predictions: [PredictionPeriod] = []
        var nextStartDate = lastRecord.startDate

        // 如果最后一次记录还在进行中,从预估结束日期后开始预测
        if lastRecord.isOngoing {
            nextStartDate = nextStartDate.adding(days: periodDuration)
        }

        let today = Date().startOfDay()
        let daysAhead = settings.predictionDaysAhead
        let predictionEndDate = today.adding(days: daysAhead)

        // 生成下一个预测周期
        nextStartDate = nextStartDate.adding(days: averageCycle)

        if nextStartDate <= predictionEndDate {
            let periodEndDate = nextStartDate.adding(days: periodDuration - 1)
            predictions.append(PredictionPeriod(startDate: nextStartDate, endDate: periodEndDate))
        }

        return predictions
    }

    // MARK: - 计算平均周期

    func calculateAverageCycle(from records: [PeriodRecord]) -> Int? {
        let sortedRecords = records.sorted { $0.startDate < $1.startDate }
        guard sortedRecords.count >= 2 else { return nil }

        var gaps: [Int] = []
        for i in 1..<sortedRecords.count {
            let gap = sortedRecords[i].startDate.startOfDay().daysSince(sortedRecords[i - 1].startDate.startOfDay())
            if gap > 0 {
                gaps.append(gap)
            }
        }

        guard !gaps.isEmpty else { return nil }
        let average = gaps.reduce(0, +) / gaps.count
        return average > 0 ? average : nil
    }

    // MARK: - 获取当前经期信息

    func getCurrentPeriodInfo(on date: Date, records: [PeriodRecord]) -> (isInPeriod: Bool, dayNumber: Int?, record: PeriodRecord?) {
        let dateToCheck = date.startOfDay()

        for record in records {
            let startDate = record.startDate.startOfDay()
            let endDate = (record.endDate ?? record.startDate).startOfDay()

            if dateToCheck >= startDate && dateToCheck <= endDate {
                let components = Calendar.current.dateComponents([.day], from: startDate, to: dateToCheck)
                let dayNumber = (components.day ?? 0) + 1
                return (true, dayNumber, record)
            }
        }

        return (false, nil, nil)
    }

    // MARK: - 获取周日期

    func getWeekDates(containing date: Date) -> [Date] {
        let weekStart = date.getWeekStart()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
}

struct PredictionPeriod {
    let startDate: Date
    let endDate: Date
}
