import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = PeriodViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // ===== 背景渐变(铺满全屏,含安全区) =====
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.961, green: 0.851, blue: 0.918),  // #F5D9EB
                        Color(red: 0.949, green: 0.749, blue: 0.867),  // #F2BFDD
                        Color(red: 0.937, green: 0.651, blue: 0.816)   // #F0A6D0
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // ===== 上半屏内容区(52% 高度) =====
                VStack(alignment: .center, spacing: 0) {
                    // A. 顶部栏(日期 + 菜单)
                    TopBar(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.08)

                    // B. 周历条
                    WeekCalendar(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.15)
                        .padding(.top, geometry.size.height * 0.04)

                    // C. 经期文本("第 X 天")
                    PeriodStatusText(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.12)
                        .padding(.top, geometry.size.height * 0.06)

                    // D. 主按钮
                    ActionButton(viewModel: viewModel)
                        .frame(height: geometry.size.height * 0.10)
                        .padding(.top, geometry.size.height * 0.04)
                        .padding(.horizontal, geometry.size.width * 0.1)

                    // 内容区底部间距(保留在上半屏内)
                    Spacer()
                        .frame(height: geometry.size.height * 0.03)
                }
                .frame(height: geometry.size.height * 0.52, alignment: .top)
                .frame(maxWidth: .infinity)

                // ===== 下半屏纯背景留白(48% 高度) =====
                // (自动由背景填充,不添加任何控件)
                VStack {
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.48, alignment: .top)
                .offset(y: geometry.size.height * 0.52)

                // ===== 设置抽屉(覆盖层) =====
                SettingsDrawer(viewModel: viewModel)
            }
            .ignoresSafeArea()
            .sheet(isPresented: $viewModel.showRecordSheet) {
                RecordPeriodSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                EditPeriodSheet(viewModel: viewModel)
            }
        }
    }
}

// ===== 顶部栏组件(重写) =====
struct TopBar: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        HStack(spacing: 0) {
            // 左: 菜单按钮(紫色)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.showSettingsDrawer.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.appPurple)
                    .font(.system(size: 20, weight: .semibold))
            }
            .frame(width: 50, height: 50)

            Spacer()

            // 中: 日期标题(白色)
            Text(viewModel.displayDateText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // 右: 占位(保持平衡)
            Color.clear.frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// ===== 经期文本组件(新增) =====
struct PeriodStatusText: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        VStack(spacing: 4) {
            Text("经期:")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 0) {
                Text("第 ")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.black)

                if let day = viewModel.currentPeriodDay {
                    Text("\(day)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.periodRed)
                } else {
                    Text("--")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.black.opacity(0.2))
                }

                Text(" 天")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

// ===== 主按钮组件(新增) =====
struct ActionButton: View {
    @ObservedObject var viewModel: PeriodViewModel

    var body: some View {
        Button(action: {
            if viewModel.isInPeriod {
                viewModel.showEditSheet = true
            } else {
                viewModel.showRecordSheet = true
            }
        }) {
            Text(viewModel.actionButtonTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appPurple)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(24)
        }
    }
}

#Preview {
    MainView()
}
