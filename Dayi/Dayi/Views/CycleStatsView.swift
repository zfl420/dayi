import SwiftUI

/// 周期统计页面
struct CycleStatsView: View {
    @ObservedObject var viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color(red: 242/255, green: 242/255, blue: 242/255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: geometry.size.height * 0.0235) {
                            CycleStatsHeader(
                                averageDays: viewModel.averageCycleDays,
                                geometry: geometry
                            )
                            .padding(.top, geometry.size.height * 0.0235)

                            ZStack(alignment: .topLeading) {
                                VStack(spacing: geometry.size.height * 0.01504) {
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
        .navigationTitle("周期天数")
        .navigationBarTitleDisplayMode(.inline)
    }
}
