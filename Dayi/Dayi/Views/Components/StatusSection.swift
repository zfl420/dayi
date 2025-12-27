import SwiftUI

struct StatusSection: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        VStack(spacing: 18) {
            // 经期天数显示 - 精确按照设计稿
            VStack(spacing: 6) {
                Text("经期:")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 0) {
                    Text("第 ")
                        .font(.system(size: 32, weight: .bold))

                    if let day = viewModel.currentPeriodDay {
                        Text("\(day)")
                            .font(.system(size: 56, weight: .bold))
                    } else {
                        Text("--")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.black.opacity(0.15))
                    }

                    Text(" 天")
                        .font(.system(size: 32, weight: .bold))
                }
                .foregroundColor(.black)
            }

            // 操作按钮 - 胶囊形白色按钮
            Button(action: {
                if viewModel.isInPeriod {
                    viewModel.showEditSheet = true
                } else {
                    viewModel.showRecordSheet = true
                }
            }) {
                Text(viewModel.actionButtonTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appPurple)
                    .frame(height: 42)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(21)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 0)
    }
}
