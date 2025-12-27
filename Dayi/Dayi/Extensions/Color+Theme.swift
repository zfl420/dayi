import SwiftUI

extension Color {
    // 紫色图标 - 设计稿中的紫色
    static let appPurple = Color(red: 0.55, green: 0.34, blue: 0.84) // #8C57D6

    // 经期标记红色
    static let appRed = Color(red: 0.96, green: 0.35, blue: 0.52) // #F55A85

    // 粉色渐变背景 - 精确按照设计稿
    static let lightPink = Color(red: 0.96, green: 0.85, blue: 0.92) // #F5D9EB
    static let darkPink = Color(red: 0.94, green: 0.71, blue: 0.84) // #F0B5D6

    static let pinkGradient = LinearGradient(
        gradient: Gradient(colors: [Color.lightPink, Color.darkPink]),
        startPoint: .top,
        endPoint: .bottom
    )
}
