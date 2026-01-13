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

    private var cycleItems: [(title: String, value: String, iconName: String, isLink: Bool)] {
        [
            (title: "上一个月经周期天数", value: lastCycleDaysText, iconName: "clock.arrow.circlepath", isLink: false),
            (title: "月经周期天数变化", value: cycleRangeText, iconName: "arrow.left.and.right.circle", isLink: true),
            (title: "经期长度变化", value: periodLengthRangeText, iconName: "drop.fill", isLink: true)
        ]
    }

    var body: some View {
        HStack(spacing: geometry.size.width * 0.0204) {
            ForEach(cycleItems.indices, id: \.self) { index in
                let item = cycleItems[index]
                Group {
                    if item.isLink {
                        NavigationLink(destination: destinationView(for: index)) {
                            statCard(title: item.title, value: item.value, iconName: item.iconName)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        statCard(title: item.title, value: item.value, iconName: item.iconName)
                    }
                }
            }
        }
        .padding(.horizontal, geometry.size.width * 0.0509)
    }

    @ViewBuilder
    private func destinationView(for index: Int) -> some View {
        switch index {
        case 1:
            CycleStatsView(viewModel: viewModel)
        case 2:
            PeriodLengthStatsView(viewModel: viewModel)
        default:
            EmptyView()
        }
    }

    private func statCard(title: String, value: String, iconName: String) -> some View {
        VStack(spacing: geometry.size.height * 0.0070) {
            Image(systemName: iconName)
                .font(.system(size: geometry.size.height * 0.0153, weight: .semibold))
                .foregroundColor(Color(red: 1.000, green: 0.353, blue: 0.490).opacity(0.75))

            Text(value)
                .font(.system(size: geometry.size.height * 0.0199, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.169, green: 0.145, blue: 0.153))

            Text(title)
                .font(.system(size: geometry.size.height * 0.0106, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.555, green: 0.506, blue: 0.518))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.0176)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.0356)
                .fill(Color.white.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.0356)
                .stroke(Color(red: 1.000, green: 0.353, blue: 0.490).opacity(0.08), lineWidth: geometry.size.height * 0.0012)
        )
        .shadow(color: Color.black.opacity(0.04), radius: geometry.size.height * 0.0047, x: 0, y: geometry.size.height * 0.0023)
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color(red: 248/255, green: 243/255, blue: 241/255)
                .ignoresSafeArea()

            MenstrualCycleInfo(
                geometry: geometry,
                viewModel: PeriodViewModel()
            )
        }
    }
}
