import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = PeriodViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 背景渐变 - 精确按照设计稿
            PinkGradientBackground()

            VStack(spacing: 0) {
                // 顶部栏 - 紫色图标 + 日期
                TopBar(viewModel: viewModel)

                // 周日历区域 - 紧接着顶部栏
                WeekCalendar(viewModel: viewModel)
                    .padding(.top, 16)

                // 经期状态区域 - 显示"第 X 天"
                StatusSection(viewModel: viewModel)
                    .padding(.top, 32)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // 设置抽屉
            SettingsDrawer(viewModel: viewModel)
        }
        .ignoresSafeArea()
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
