import SwiftUI

struct StatusSection: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        VStack(spacing: 20) {
            // 经期天数显示
            VStack(spacing: 8) {
                Text("经期:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                if let day = viewModel.currentPeriodDay {
                    HStack(spacing: 4) {
                        Text("第")
                        Text("\(day)")
                            .font(.system(size: 48, weight: .bold))
                        Text("天")
                    }
                    .foregroundColor(.black)
                } else {
                    Text("--")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black.opacity(0.3))
                }
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
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}
