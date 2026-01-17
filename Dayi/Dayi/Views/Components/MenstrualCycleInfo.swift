//
//  MenstrualCycleInfo.swift
//  Dayi
//
//  Created by Claude on 2026/1/1.
//

import SwiftUI

struct MenstrualCycleInfo: View {
    let geometry: GeometryProxy
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
            // 标题区域
            Text("我的月经周期")
                .font(.pingFang(size: geometry.size.height * 0.025, weight: .semibold)) // 标题字号
                .foregroundColor(Color("Hex111827"))

            // 3个独立的小卡片
            VStack(spacing: geometry.size.height * 0.012) {
                // 第一个卡片：上一个月经周期天数
                singleCardView(
                    title: cycleItems[0].0,
                    value: cycleItems[0].1,
                    isClickable: false,
                    destination: nil
                )

                // 第二个卡片：月经周期天数变化
                singleCardView(
                    title: cycleItems[1].0,
                    value: cycleItems[1].1,
                    isClickable: true,
                    destination: AnyView(CycleStatsView(viewModel: viewModel))
                )

                // 第三个卡片：经期长度变化
                singleCardView(
                    title: cycleItems[2].0,
                    value: cycleItems[2].1,
                    isClickable: true,
                    destination: AnyView(PeriodLengthStatsView(viewModel: viewModel))
                )
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0509) // 整体区域左右边距
    }

    // 单个卡片视图
    @ViewBuilder
    private func singleCardView(title: String, value: String, isClickable: Bool, destination: AnyView?) -> some View {
        let cardContent = HStack(spacing: 0) {
            // 左侧文字区域
            VStack(alignment: .leading, spacing: geometry.size.height * 0.0047) {
                // 灰色小标题
                Text(title)
                    .font(.pingFang(size: geometry.size.height * 0.018)) // 小标题字号
                    .foregroundColor(Color("Hex6B7280")) // 灰色文字颜色

                // 黑色粗体数据
                Text(value)
                    .font(.pingFang(size: geometry.size.height * 0.023, weight: .medium)) // 数据字号
                    .foregroundColor(Color("Hex111827"))
            }

            Spacer()

            // 右侧箭头（仅可点击的卡片显示）
            if isClickable {
                Text("›")
                    .font(.pingFang(size: 30, weight: .regular))
                    .foregroundColor(Color("Hex6B7280")) // 箭头颜色
                    .padding(.trailing, geometry.size.width * 0.0204) // 箭头右侧边距
            }
        }
        .frame(height: geometry.size.height * 0.0558) // 卡片高度
        .padding(.horizontal, geometry.size.width * 0.0407) // 卡片左右内边距
        .padding(.vertical, geometry.size.height * 0.0235) // 卡片上下内边距
        .background(Color("HexFEFFFF").opacity(0.5)) // 半透明白色背景
        .cornerRadius(geometry.size.width * 0.0305) // 卡片圆角
        .contentShape(Rectangle()) // 扩大可点击区域

        if isClickable, let destination = destination {
            NavigationLink(destination: destination) {
                cardContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            cardContent
        }
    }

}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color("HexFEFFFF")
                .ignoresSafeArea()

            MenstrualCycleInfo(
                geometry: geometry,
                viewModel: PeriodViewModel()
            )
        }
    }
}
