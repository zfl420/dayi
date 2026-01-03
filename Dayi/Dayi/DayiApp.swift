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
        // 全局配置导航栏外观：隐藏所有页面的导航栏分隔线
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear  // 隐藏分隔线
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // 设置返回按钮颜色
        UINavigationBar.appearance().tintColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
