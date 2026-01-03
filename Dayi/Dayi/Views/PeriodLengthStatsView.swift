import SwiftUI

/// 经期天数统计页面
struct PeriodLengthStatsView: View {
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
                            PeriodLengthStatsHeader(
                                averageDays: viewModel.averagePeriodDays,
                                geometry: geometry
                            )
                            .padding(.top, geometry.size.height * 0.0235)

                            ZStack(alignment: .topLeading) {
                                VStack(spacing: geometry.size.height * 0.01504) {
                                    if let currentPeriod = viewModel.currentPeriod {
                                        CurrentPeriodCard(
                                            periodData: currentPeriod,
                                            averageDays: viewModel.averagePeriodDays,
                                            maxPeriodDays: viewModel.maxPeriodDays,
                                            geometry: geometry
                                        )
                                    }

                                    if !viewModel.historicalPeriods.isEmpty {
                                        ForEach(viewModel.historicalPeriods.reversed()) { period in
                                            HistoryPeriodRow(
                                                period: period,
                                                averageDays: viewModel.averagePeriodDays,
                                                maxPeriodDays: viewModel.maxPeriodDays,
                                                geometry: geometry
                                            )
                                        }
                                    }
                                }

                                PeriodAverageReferenceLine(
                                    averageDays: viewModel.averagePeriodDays,
                                    maxPeriodDays: viewModel.maxPeriodDays,
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
        .onAppear {
            // 隐藏返回按钮文字
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
