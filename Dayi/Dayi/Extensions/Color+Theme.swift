import SwiftUI

extension Color {
    static let appPurple = Color(red: 0.533, green: 0.373, blue: 0.855)
    static let appRed = Color(red: 1.0, green: 0.302, blue: 0.427)
    static let lightPink = Color(red: 0.980, green: 0.847, blue: 0.910)
    static let darkPink = Color(red: 0.961, green: 0.752, blue: 0.843)

    static let pinkGradient = LinearGradient(
        gradient: Gradient(colors: [Color.lightPink, Color.darkPink]),
        startPoint: .top,
        endPoint: .bottom
    )
}
