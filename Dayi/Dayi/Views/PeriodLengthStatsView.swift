import SwiftUI

/// 经期天数统计页面
struct PeriodLengthStatsView: View {
    @ObservedObject var viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            let averageDays = viewModel.averagePeriodDays
            let maxDays = viewModel.maxPeriodDays
            let historicalPeriods = viewModel.historicalPeriods
            let currentPeriod = viewModel.currentPeriod

            ZStack(alignment: .top) {
                Color(red: 242/255, green: 242/255, blue: 242/255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: geometry.size.height * 0.0235) {
                            PeriodLengthStatsHeader(
                                averageDays: averageDays,
                                geometry: geometry
                            )
                            .padding(.top, geometry.size.height * 0.0235)

                            ZStack(alignment: .topLeading) {
                                VStack(spacing: geometry.size.height * 0.01504) {
                                    if let currentPeriod = currentPeriod {
                                        CurrentPeriodCard(
                                            periodData: currentPeriod,
                                            averageDays: averageDays,
                                            maxPeriodDays: maxDays,
                                            geometry: geometry
                                        )
                                    }

                                    if !historicalPeriods.isEmpty {
                                        ForEach(historicalPeriods.reversed()) { period in
                                            HistoryPeriodRow(
                                                period: period,
                                                averageDays: averageDays,
                                                maxPeriodDays: maxDays,
                                                geometry: geometry
                                            )
                                        }
                                    }
                                }

                                PeriodAverageReferenceLine(
                                    averageDays: averageDays,
                                    maxPeriodDays: maxDays,
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
        .navigationTitle("经期天数")
        .navigationBarTitleDisplayMode(.inline)
    }
}
