import UIKit

enum NavigationBarStyle {
    static func applyDefault() {
        apply(backgroundColor: UIColor(named: "HexFEFFFF") ?? .white)
    }

    static func applyPageBackground() {
        apply(backgroundColor: UIColor(named: "HexFEFFFF") ?? .white)
    }

    private static func apply(backgroundColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "Hex333333") ?? .black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "Hex333333") ?? .black
        ]

        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(
            UIColor(named: "Hex333333") ?? .black,
            renderingMode: .alwaysOriginal
        )
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
