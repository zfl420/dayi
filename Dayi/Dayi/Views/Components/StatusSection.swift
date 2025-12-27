import SwiftUI

struct StatusSection: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        VStack(spacing: 16) {
            // 经期天数显示
            VStack(spacing: 4) {
                Text("经期:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 2) {
                    Text("第")
                        .font(.system(size: 28, weight: .semibold))

                    if let day = viewModel.currentPeriodDay {
                        Text("\(day)")
                            .font(.system(size: 48, weight: .bold))
                    } else {
                        Text("--")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.black.opacity(0.2))
                    }

                    Text("天")
                        .font(.system(size: 28, weight: .semibold))
                }
                .foregroundColor(.black)
            }

            // 操作按钮
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
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}
