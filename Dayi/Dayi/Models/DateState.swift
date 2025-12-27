import Foundation

enum DateState: Equatable {
    case normal
    case selected
    case actualPeriod(day: Int)
    case predictedPeriod
    case actualAndSelected(day: Int)
    case predictedAndSelected
}
