//
//  MenstrualCycleInfo.swift
//  Dayi
//
//  Created by Claude on 2026/1/1.
//

import SwiftUI

struct MenstrualCycleInfo: View {
    let geometry: GeometryProxy

    // 数据数组（当前写死）
    let cycleItems = [
        ("上一个月经周期长度", "29天"),
        ("月经周期长度变化", "29-36天"),
        ("上一个经期长度", "5天"),
        ("经期长度变化", "6-7天")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            // 标题区域
            Text("我的月经周期")
                .font(.system(size: geometry.size.height * 0.0211, weight: .semibold)) // 标题字号
                .foregroundColor(.black)
//                .padding(.leading, geometry.size.width * 0) // 标题左侧边距

            // 白色卡片内容区
            VStack(spacing: 0) {
                ForEach(Array(cycleItems.enumerated()), id: \.offset) { index, item in
                    // 单项内容行
                    HStack(spacing: 0) {
                        // 左侧文字区域
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.0047) {
                            // 灰色小标题
                            Text(item.0)
                                .font(.system(size: geometry.size.height * 0.02)) // 小标题字号
                                .foregroundColor(Color(red: 90/255, green: 87/255, blue: 86/255)) // 灰色文字颜色

                            // 黑色粗体数据
                            Text(item.1)
                                .font(.system(size: geometry.size.height * 0.025, weight: .semibold)) // 数据字号
                                .foregroundColor(.black)
                        }

                        Spacer()

                        // 右侧箭头图标
                        Image(systemName: "chevron.right")
                            .font(.system(size: geometry.size.width * 0.0407)) // 箭头尺寸
                            .foregroundColor(Color(red: 90/255, green: 87/255, blue: 86/255)) // 箭头颜色
                            .padding(.trailing, geometry.size.width * 0.0204) // 箭头右侧边距
                    }
                    .frame(height: geometry.size.height * 0.0657) // 单项行高
                    .contentShape(Rectangle()) // 扩大可点击区域
                    .padding(.horizontal, geometry.size.width * 0.0407) // 单项左右内边距

                    // 分割线
                    if index < cycleItems.count - 1 {
                        Rectangle()
                            .fill(Color(red: 240/255, green: 240/255, blue: 240/255)) // 分割线颜色
                            .frame(height: 1) // 分割线高度
                            .padding(.horizontal, geometry.size.width * 0.0407) // 分割线左右边距
                    }
                }
            }
            .background(Color.white) // 卡片白色背景
            .cornerRadius(geometry.size.width * 0.0305) // 卡片圆角
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2) // 卡片阴影
        }
        .padding(.horizontal, geometry.size.width * 0.0509) // 整体区域左右边距
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color(red: 248/255, green: 243/255, blue: 241/255)
                .ignoresSafeArea()

            MenstrualCycleInfo(geometry: geometry)
        }
    }
}
