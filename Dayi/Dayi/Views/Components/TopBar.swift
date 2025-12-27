import SwiftUI

struct TopBar: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        HStack(spacing: 0) {
            // 左侧: 紫色图标按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.showSettingsDrawer.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.appPurple)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)

            Spacer()

            // 中间: 动态日期 - 白色文字
            Text(viewModel.displayDateText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // 右侧: 占位符保持平衡
            Color.clear.frame(width: 44)
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }
}
