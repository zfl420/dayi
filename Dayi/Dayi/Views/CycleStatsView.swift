import SwiftUI

/// 周期统计页面
struct CycleStatsView: View {
    @ObservedObject var viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            let averageDays = viewModel.averageCycleDays
            let maxDays = viewModel.maxCycleDays
            let completedCycles = viewModel.completedCycles
            let currentCycle = viewModel.currentCycle

            ZStack(alignment: .top) {
                Color.pageBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: geometry.size.height * 0.0235) {
                            CycleStatsHeader(
                                averageDays: averageDays,
                                geometry: geometry
                            )
                            .padding(.top, geometry.size.height * 0.0235)

                            ZStack(alignment: .topLeading) {
                                VStack(spacing: geometry.size.height * 0.01504) {
                                    if let currentCycle = currentCycle {
                                        CurrentCycleCard(
                                            cycleData: currentCycle,
                                            averageDays: averageDays,
                                            maxCycleDays: maxDays,
                                            geometry: geometry
                                        )
                                    }

                                    if !completedCycles.isEmpty {
                                        ForEach(completedCycles.reversed()) { cycle in
                                            HistoryCycleRow(
                                                cycle: cycle,
                                                averageDays: averageDays,
                                                maxCycleDays: maxDays,
                                                geometry: geometry
                                            )
                                        }
                                    }
                                }

                                AverageReferenceLine(
                                    averageDays: averageDays,
                                    maxCycleDays: maxDays,
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
        .onAppear {
            NavigationBarStyle.applyPageBackground()
        }
        .onDisappear {
            NavigationBarStyle.applyDefault()
        }
    }
}
