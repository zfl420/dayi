import UIKit

enum NavigationBarStyle {
    static func applyDefault() {
        apply(backgroundColor: UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.9))
    }

    static func applyPageBackground() {
        apply(backgroundColor: UIColor(red: 254/255, green: 255/255, blue: 255/255, alpha: 1.0))
    }

    private static func apply(backgroundColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        ]

        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(
            UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),
            renderingMode: .alwaysOriginal
        )
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
