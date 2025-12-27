import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = PeriodViewModel()

    var body: some View {
        ZStack {
            // 背景渐变
            PinkGradientBackground()

            VStack(spacing: 0) {
                // 顶部栏
                TopBar(viewModel: viewModel)

                // 周日历
                WeekCalendar(viewModel: viewModel)
                    .padding(.top, 12)

                // 状态展示区
                StatusSection(viewModel: viewModel)
                    .padding(.top, 28)

                Spacer()
            }

            // 设置抽屉
            SettingsDrawer(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showRecordSheet) {
            RecordPeriodSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            EditPeriodSheet(viewModel: viewModel)
        }
    }
}

#Preview {
    MainView()
}
