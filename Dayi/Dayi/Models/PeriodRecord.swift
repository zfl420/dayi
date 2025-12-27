import Foundation

struct PeriodRecord: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    let createdAt: Date
    var updatedAt: Date

    init(startDate: Date, endDate: Date? = nil) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    var duration: Int? {
        guard let endDate = endDate else { return nil }
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    var isOngoing: Bool {
        endDate == nil
    }
}
