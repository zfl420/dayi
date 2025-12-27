import Foundation

class PeriodDataManager {
    private let recordsKey = "period_records"
    private let settingsKey = "app_settings"

    func saveRecords(_ records: [PeriodRecord]) {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }

    func loadRecords() -> [PeriodRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([PeriodRecord].self, from: data)
        } catch {
            return []
        }
    }

    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else {
            return AppSettings()
        }
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return AppSettings()
        }
    }

    func addRecord(startDate: Date) -> PeriodRecord {
        let record = PeriodRecord(startDate: startDate.startOfDay())
        var records = loadRecords()
        records.append(record)
        saveRecords(records)
        return record
    }

    func updateRecordEndDate(recordId: UUID, endDate: Date) {
        var records = loadRecords()
        if let index = records.firstIndex(where: { $0.id == recordId }) {
            records[index].endDate = endDate.startOfDay()
            records[index].updatedAt = Date()
            saveRecords(records)
        }
    }

    func deleteRecord(recordId: UUID) {
        var records = loadRecords()
        records.removeAll { $0.id == recordId }
        saveRecords(records)
    }

    func getLatestRecord() -> PeriodRecord? {
        loadRecords().sorted { $0.startDate > $1.startDate }.first
    }
}
