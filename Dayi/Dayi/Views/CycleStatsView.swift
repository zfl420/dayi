import SwiftUI

/// 周期统计页面
struct CycleStatsView: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 242/255, green: 242/255, blue: 242/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: geometry.size.height * 0.0235) {
                        CycleStatsHeader(
                            averageDays: viewModel.averageCycleDays,
                            geometry: geometry
                        )
                        .padding(.top, geometry.size.height * 0.0235)

                        ZStack(alignment: .topLeading) {
                            VStack(spacing: geometry.size.height * 0.0188) {
                                if let currentCycle = viewModel.currentCycle {
                                    CurrentCycleCard(
                                        cycleData: currentCycle,
                                        averageDays: viewModel.averageCycleDays,
                                        maxCycleDays: viewModel.maxCycleDays,
                                        geometry: geometry
                                    )
                                }

                                if !viewModel.completedCycles.isEmpty {
                                    ForEach(viewModel.completedCycles.reversed()) { cycle in
                                        HistoryCycleRow(
                                            cycle: cycle,
                                            averageDays: viewModel.averageCycleDays,
                                            maxCycleDays: viewModel.maxCycleDays,
                                            geometry: geometry
                                        )
                                    }
                                }
                            }

                            AverageReferenceLine(
                                averageDays: viewModel.averageCycleDays,
                                maxCycleDays: viewModel.maxCycleDays,
                                geometry: geometry
                            )
                        }

                        Spacer()
                            .frame(height: geometry.size.height * 0.0588)
                    }
                    .padding(.horizontal, geometry.size.width * 0.0509)
                }
            }
        }
    }

    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: geometry.size.height * 0.0282, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.leading, geometry.size.width * 0.0509)

            Spacer()

            Text("周期天数")
                .font(.system(size: geometry.size.height * 0.0282, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Color.clear
                .frame(width: geometry.size.width * 0.0509 + geometry.size.height * 0.0282)
        }
        .frame(height: geometry.size.height * 0.0517)
    }
}
