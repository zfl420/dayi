//
//  MenstrualCycleInfo.swift
//  Dayi
//
//  Created by Claude on 2026/1/1.
//

import SwiftUI

struct MenstrualCycleInfo: View {
    let geometry: GeometryProxy
    @Binding var showCycleStats: Bool
    @Binding var showPeriodStats: Bool
    @ObservedObject var viewModel: PeriodViewModel

    // 上一个周期天数
    private var lastCycleDaysText: String {
        let cycles = viewModel.completedCycles
        guard let lastCycle = cycles.last else { return "-" }
        return "\(lastCycle.cycleDays)天"
    }

    // 计算周期天数范围
    private var cycleRangeText: String {
        let cycles = viewModel.completedCycles
        guard !cycles.isEmpty else { return "-" }

        let cycleDays = cycles.map { $0.cycleDays }
        let minDays = cycleDays.min() ?? 0
        let maxDays = cycleDays.max() ?? 0

        if minDays == maxDays {
            return "\(minDays)天"
        } else {
            return "\(minDays)-\(maxDays)天"
        }
    }

    // 计算经期长度范围
    private var periodLengthRangeText: String {
        let cycles = viewModel.completedCycles
        guard !cycles.isEmpty else { return "-" }

        let periodDays = cycles.map { $0.periodDays }
        let minDays = periodDays.min() ?? 0
        let maxDays = periodDays.max() ?? 0

        if minDays == maxDays {
            return "\(minDays)天"
        } else {
            return "\(minDays)-\(maxDays)天"
        }
    }

    // 月经周期数据
    private var cycleItems: [(String, String)] {
        [
            ("上一个月经周期天数", lastCycleDaysText),
            ("月经周期天数变化", cycleRangeText),
            ("经期长度变化", periodLengthRangeText)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            // 月经周期模块
            sectionView(title: "我的月经周期", items: cycleItems)
        }
        .padding(.horizontal, geometry.size.width * 0.0509) // 整体区域左右边距
    }

    // 可复用的模块视图
    @ViewBuilder
    private func sectionView(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            // 标题区域
            Text(title)
                .font(.system(size: geometry.size.height * 0.025, weight: .semibold)) // 标题字号
                .foregroundColor(.black)

            // 白色卡片内容区
            VStack(spacing: geometry.size.height * 0.02) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    // 单项内容行
                    HStack(spacing: 0) {
                        // 左侧文字区域
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.0047) {
                            // 灰色小标题
                            Text(item.0)
                                .font(.system(size: geometry.size.height * 0.018)) // 小标题字号
                                .foregroundColor(Color(red: 90/255, green: 87/255, blue: 86/255)) // 灰色文字颜色

                            // 黑色粗体数据
                            Text(item.1)
                                .font(.system(size: geometry.size.height * 0.023, weight: .medium)) // 数据字号
                                .foregroundColor(.black)
                        }

                        Spacer()

                        // 右侧内容区域
                        if index == 0 {
                            // 上一个周期长度:显示绿色对勾和"正常"文本
                            HStack(spacing: geometry.size.width * 0.0153) {
                                // 绿色圆形对勾
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 52/255, green: 199/255, blue: 89/255)) // 绿色背景
                                        .frame(width: geometry.size.width * 0.0458, height: geometry.size.width * 0.0458) // 圆形尺寸

                                    Image(systemName: "checkmark")
                                        .font(.system(size: geometry.size.width * 0.0255, weight: .semibold)) // 对勾尺寸
                                        .foregroundColor(.white) // 白色对勾
                                }

                                // "正常"文本
                                Text("正常")
                                    .font(.system(size: geometry.size.height * 0.0164)) // 正常文本字号
                                    .foregroundColor(Color(red: 90/255, green: 87/255, blue: 86/255)) // 灰色文字
                            }
                            .padding(.trailing, geometry.size.width * 0.0204) // 右侧边距
                        } else {
                            // 周期变化和经期长度变化:显示箭头
                            Image(systemName: "chevron.right")
                                .font(.system(size: geometry.size.width * 0.04)) // 箭头尺寸
                                .foregroundColor(Color(red: 90/255, green: 87/255, blue: 86/255)) // 箭头颜色
                                .padding(.trailing, geometry.size.width * 0.0204) // 箭头右侧边距
                        }
                    }
                    .frame(height: geometry.size.height * 0.0657) // 单项行高
                    .contentShape(Rectangle()) // 扩大可点击区域
                    .padding(.horizontal, geometry.size.width * 0.0407) // 单项左右内边距
                    .onTapGesture {
                        if index == 1 {
                            showCycleStats = true
                        } else if index == 2 {
                            showPeriodStats = true
                        }
                    }

                    // 分割线
                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color(red: 240/255, green: 240/255, blue: 240/255)) // 分割线颜色
                            .frame(height: 1) // 分割线高度
                            .padding(.horizontal, geometry.size.width * 0.0407) // 分割线左右边距
                    }
                }
            }
            .padding(.vertical, geometry.size.height * 0.0235) // 白色卡片上下内边距
            .background(Color.white) // 卡片白色背景
            .cornerRadius(geometry.size.width * 0.0305) // 卡片圆角
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color(red: 248/255, green: 243/255, blue: 241/255)
                .ignoresSafeArea()

            MenstrualCycleInfo(
                geometry: geometry,
                showCycleStats: .constant(false),
                showPeriodStats: .constant(false),
                viewModel: PeriodViewModel()
            )
        }
    }
}
