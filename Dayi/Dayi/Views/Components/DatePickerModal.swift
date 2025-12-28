import SwiftUI

/// 日期选择器弹窗（原生抽屉式）
struct DatePickerModal: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        // 使用 .sheet 替代自定义弹窗
        // 注意：.sheet 需要在父视图中调用
        EmptyView()
    }
}

/// 日期选择器内容视图（用于 sheet）
struct DatePickerSheetContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    // 格式化选中的日期
    private var selectedDateText: String {
        let calendar = Calendar.current
        let selectedYear = calendar.component(.year, from: viewModel.tempSelectedDate)
        let currentYear = calendar.component(.year, from: Date())

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        if selectedYear == currentYear {
            // 今年：显示 "12月27日"
            formatter.dateFormat = "M月d日"
        } else {
            // 非今年：显示 "2024年12月24日"
            formatter.dateFormat = "yyyy年M月d日"
        }

        return formatter.string(from: viewModel.tempSelectedDate)
    }

    private var topBackgroundColor: Color {
        Color(red: 250/255.0, green: 250/255.0, blue: 250/255.0)  // #FAFAFA
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部日期展示
            Text(selectedDateText)
                .font(.system(size: geometry.size.height * 0.0235, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, geometry.size.height * 0.025)
                .padding(.bottom, geometry.size.height * 0.015)
                .frame(maxWidth: .infinity)
                .background(topBackgroundColor)

            // 日期选择内容
            DatePickerContent(viewModel: viewModel, geometry: geometry, topBackgroundColor: topBackgroundColor)

            // 工具栏（移到底部）
            DatePickerToolbar(viewModel: viewModel, geometry: geometry)
                .padding(.bottom, geometry.size.height * 0.02)
        }
        .background(Color.white)
        .presentationDetents([.fraction(0.99)])
        .presentationDragIndicator(.visible)
    }
}
