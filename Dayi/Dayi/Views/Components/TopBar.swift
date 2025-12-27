import SwiftUI

struct TopBar: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        HStack(spacing: 16) {
            // 左侧: 紫色图标按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.showSettingsDrawer.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.appPurple)
                    .font(.system(size: 20, weight: .semibold))
            }
            .frame(width: 40, height: 40)

            Spacer()

            // 中间: 动态日期
            Text(viewModel.displayDateText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // 右侧: 占位符保持平衡
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
