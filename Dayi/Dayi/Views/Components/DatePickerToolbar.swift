import SwiftUI

/// 日期选择器顶部工具栏
struct DatePickerToolbar: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        HStack {
            // 取消按钮
            Button(action: {
                viewModel.closeDatePicker()
            }) {
                Text("取消")
                    .font(.system(size: geometry.size.height * 0.0235, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
            }

            Spacer()

            // 今天按钮 - 只在今天不可见时显示
            if !viewModel.isTodayVisible {
                Button(action: {
                    viewModel.scrollToToday()
                }) {
                    Text("今天")
                        .font(.system(size: geometry.size.height * 0.02, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.vertical, geometry.size.height * 0.005)
                        .background(Color(red: 1.0, green: 230/255.0, blue: 235/255.0))
                        .cornerRadius(geometry.size.height * 0.01)
                }
                .transition(.opacity)
            }

            Spacer()

            // 保存按钮
            Button(action: {
                viewModel.savePeriodRecords()
            }) {
                Text("保存")
                    .font(.system(size: geometry.size.height * 0.0235, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
            }
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.vertical, geometry.size.height * 0.015)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isTodayVisible)
    }
}
