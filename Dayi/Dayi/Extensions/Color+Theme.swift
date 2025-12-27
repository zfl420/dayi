import SwiftUI

extension Color {
    // ===== 颜色常量 =====
    // 菜单图标 - 紫色
    static let appPurple = Color(red: 0.533, green: 0.345, blue: 0.839) // #8858D6

    // 经期标记 - 粉红/珊瑚红
    static let periodRed = Color(red: 0.957, green: 0.353, blue: 0.518) // #F45A84

    // 背景渐变 - 粉色系
    static let bgGradientTop = Color(red: 0.961, green: 0.851, blue: 0.918) // #F5D9EB
    static let bgGradientMid = Color(red: 0.949, green: 0.749, blue: 0.867) // #F2BFDD
    static let bgGradientBottom = Color(red: 0.937, green: 0.651, blue: 0.816) // #F0A6D0

    static let pinkGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.bgGradientTop,
            Color.bgGradientMid,
            Color.bgGradientBottom
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 文本颜色
    static let textDark = Color.black
    static let textLight = Color.white.opacity(0.7)
}
