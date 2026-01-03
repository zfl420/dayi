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
    @Environment(\.dismiss) private var dismiss

    private var topBackgroundColor: Color {
        Color(red: 250/255.0, green: 250/255.0, blue: 250/255.0)  // #FAFAFA
    }

    var body: some View {
        VStack(spacing: 0) {
            // 日期选择内容（移除了顶部日期文本）
            DatePickerContent(viewModel: viewModel, geometry: geometry, topBackgroundColor: topBackgroundColor)

            // 工具栏（移到底部）
            DatePickerToolbar(viewModel: viewModel, geometry: geometry, dismiss: dismiss)
                .padding(.bottom, geometry.size.height * 0.02)
        }
        .background(Color.white)
        .presentationDetents([.fraction(0.99)])
        .presentationDragIndicator(.visible)
    }
}

/// 全屏页面式日期选择器
struct DatePickerFullScreenContent: View {
    @ObservedObject var viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    private var topBackgroundColor: Color {
        Color(red: 250/255.0, green: 250/255.0, blue: 250/255.0)  // #FAFAFA
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 背景：#FAFAFA 延伸到状态栏
                topBackgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 日期选择内容（完全复用，样式不变）
                    DatePickerContent(
                        viewModel: viewModel,
                        geometry: geometry,
                        topBackgroundColor: topBackgroundColor
                    )

                    // 工具栏（保持在底部）
                    DatePickerToolbar(viewModel: viewModel, geometry: geometry, dismiss: dismiss)
                        .padding(.bottom, geometry.size.height * 0.02)
                }

            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 250/255, green: 250/255, blue: 250/255), for: .navigationBar)
        .onAppear {
            // 隐藏返回按钮和标题，但保留导航栏占位
            UINavigationBar.appearance().tintColor = .clear
        }
        .onDisappear {
            // 恢复全局导航栏样式（颜色 #333333）
            UINavigationBar.appearance().tintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        }
    }
}
