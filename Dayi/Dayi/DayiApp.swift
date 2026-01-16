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
        NavigationBarStyle.applyDefault()
    }
}
