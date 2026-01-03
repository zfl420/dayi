//
//  DayiApp.swift
//  Dayi
//
//  Created by 飞 on 2025/12/26.
//

import SwiftUI

@main
struct DayiApp: App {
    init() {
        // 配置全局导航栏样式
        configureNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }

    // 统一配置导航栏外观
    private func configureNavigationBar() {
        // 导航栏背景色 #FAFAFA，透明度 30%
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.9)

        // 标题颜色 #333333
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        ]

        // 大标题颜色（如果使用大标题模式）
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        ]

        // 返回按钮颜色 #333333，隐藏返回按钮文字
        let backImage = UIImage(systemName: "chevron.left")?.withTintColor(
            UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),
            renderingMode: .alwaysOriginal
        )
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        // 隐藏返回按钮文字，只显示箭头
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        // 应用外观配置
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
