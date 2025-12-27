import SwiftUI

struct SettingsDrawer: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            // 背景遮罩
            if viewModel.showSettingsDrawer {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.showSettingsDrawer = false
                        }
                    }
            }

            // 抽屉内容
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("设置")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("经期设置")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)

                        SettingRow(
                            title: "平均周期",
                            value: "\(viewModel.settings.averageCycleDays)天"
                        )

                        SettingRow(
                            title: "经期天数",
                            value: "\(viewModel.settings.averagePeriodDays)天"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("显示预测", isOn: $viewModel.settings.showPrediction)
                            .onChange(of: viewModel.settings.showPrediction) { _ in
                                viewModel.saveData()
                            }
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("关于应用")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        Text("大姨 v1.0")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .background(Color.white)

                Spacer()
            }
            .offset(x: viewModel.showSettingsDrawer ? 0 : -UIScreen.main.bounds.width * 0.8)
            .animation(.easeInOut(duration: 0.3), value: viewModel.showSettingsDrawer)
        }
    }
}

struct SettingRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.black)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appPurple)
        }
        .padding(.vertical, 8)
    }
}
