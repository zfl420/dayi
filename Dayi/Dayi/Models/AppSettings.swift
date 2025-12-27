import Foundation

struct AppSettings: Codable {
    var averageCycleDays: Int = 28
    var averagePeriodDays: Int = 7
    var showPrediction: Bool = true
    var predictionDaysAhead: Int = 60

    init() {}
}
