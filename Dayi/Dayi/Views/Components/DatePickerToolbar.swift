import SwiftUI

/// 日期选择器顶部工具栏
struct DatePickerToolbar: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let dismiss: DismissAction

    var body: some View {
        HStack {
            // 取消按钮
            Button(action: {
                viewModel.closeDatePicker()
                dismiss()
            }) {
                    Text("取消")
                        .font(.pingFang(size: geometry.size.height * 0.0235, weight: .bold))
                    .foregroundColor(Color.datePickerAccent)
            }

            Spacer()

            // 今天按钮 - 只在今天不可见时显示
            if !viewModel.isTodayVisible {
                Button(action: {
                    viewModel.scrollToToday()
                }) {
                    Text("今天")
                        .font(.pingFang(size: geometry.size.height * 0.02, weight: .medium))
                        .foregroundColor(Color.datePickerAccent)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.vertical, geometry.size.height * 0.005)
                        .background(Color.datePickerAccent.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.01)
                }
                .transition(.opacity)
            }

            Spacer()

            // 保存按钮
            Button(action: {
                viewModel.savePeriodRecords()
                dismiss()
            }) {
                    Text("保存")
                        .font(.pingFang(size: geometry.size.height * 0.0235, weight: .bold))
                    .foregroundColor(Color.datePickerAccent)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.vertical, geometry.size.height * 0.015)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isTodayVisible)
    }
}
