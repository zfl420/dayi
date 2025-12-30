import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: PeriodViewModel

    init(viewModel: PeriodViewModel = PeriodViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // ===== 底部纯色背景 =====
                Color(red: 248/255.0, green: 243/255.0, blue: 241/255.0)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ===== 渐变背景区域的内容 =====
                    VStack(spacing: 0) {
                        // ===== 日期标题 =====
                        Text(viewModel.displayDateText)
                            .font(.system(size: geometry.size.height * 0.0188, weight: .medium)) // 16/852
                            .foregroundColor(.black)
                            .padding(.top, geometry.size.height * 0.105) // 增加顶部间距，整体下移

                        // ===== 周历 =====
                        WeekCalendar(viewModel: viewModel, geometry: geometry, isTodayInPeriod: viewModel.isTodayInPeriod)
                            .padding(.top, geometry.size.height * 0.0235) // 20/852

                        // ===== 经期状态 =====
                        PeriodStatus(viewModel: viewModel, geometry: geometry)
                            .padding(.top, geometry.size.height * 0.14) // 增加间距，让提示文案和按钮下移

                        // ===== 编辑按钮 =====
                        EditButton(viewModel: viewModel, geometry: geometry, isTodayInPeriod: viewModel.isTodayInPeriod)
                            .padding(.top, geometry.size.height * 0.05) // 按钮与提示文案的间距
                            .padding(.bottom, geometry.size.height * 0.035) // 30/852，按钮与弧形中间的间距
                    }
                    .background(
                        // ===== 渐变背景直接作为内容背景，自动适应高度 =====
                        GradientBackground(geometry: geometry, isTodayInPeriod: viewModel.isTodayInPeriod)
                    )

                    Spacer()
                }
                .fullScreenCover(isPresented: $viewModel.showDatePicker) {
                    GeometryReader { sheetGeometry in
                        DatePickerFullScreenContent(viewModel: viewModel, geometry: sheetGeometry)
                    }
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
            }
            .ignoresSafeArea()
        }
    }
}

// ===== 渐变背景组件 =====
struct GradientBackground: View {
    let geometry: GeometryProxy
    let isTodayInPeriod: Bool

    var body: some View {
        GeometryReader { backgroundGeometry in
            let contentHeight = backgroundGeometry.size.height
            // 弧形两边在 0.924 位置，中间在 1.0 位置
            // 为了让弧形中间在内容底部下方约30像素，需要额外的高度
            let extraHeight = geometry.size.height * 0.035 // 30像素
            let totalHeight = contentHeight + extraHeight

            // 根据是否在月经期选择不同的渐变色
            let topColor = isTodayInPeriod
                ? Color(red: 254/255, green: 229/255, blue: 234/255)  // #FEE5EA
                : Color(red: 243/255, green: 233/255, blue: 230/255)  // #F3E9E6

            let bottomColor = isTodayInPeriod
                ? Color(red: 255/255, green: 90/255, blue: 125/255)   // #FF5A7D
                : Color(red: 254/255, green: 255/255, blue: 254/255)  // #FEFDFD

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: topColor, location: 0.0),
                    .init(color: bottomColor, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: totalHeight)
            .clipShape(BottomCurveShape())
        }
    }
}

// ===== 经期状态组件 =====
struct PeriodStatus: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        Text("记录你上一次经期开始的日期")
            .font(.system(size: geometry.size.height * 0.0188, weight: .bold)) // 16/852, 增大字号
            .foregroundColor(.black)
    }
}

// ===== 编辑按钮组件 =====
struct EditButton: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let isTodayInPeriod: Bool

    var body: some View {
        Button(action: {
            viewModel.openDatePicker()
        }) {
            // 根据是否在月经期选择不同的文本和颜色
            let buttonText = isTodayInPeriod ? "编辑月经日期" : "记录月经"

            let textColor = isTodayInPeriod
                ? Color(red: 255/255, green: 90/255, blue: 125/255)  // #FF5A7D
                : Color.white

            let backgroundColor = isTodayInPeriod
                ? Color.white
                : Color(red: 255/255, green: 90/255, blue: 125/255)  // #FF5A7D

            Text(buttonText)
                .font(.system(size: geometry.size.height * 0.0188, weight: .bold)) // 16/852, 增大字号并加粗
                .foregroundColor(textColor)
                .padding(.horizontal, geometry.size.width * 0.0407) // 16/393, 左右边距减半
                .frame(height: geometry.size.height * 0.0468) // 39.84/852, 介于44和35.78之间
                .background(backgroundColor)
                .cornerRadius(geometry.size.height * 0.0234) // 19.93/852, 圆角相应调整
                .shadow(color: Color.black.opacity(0.1), radius: geometry.size.height * 0.0047, x: 0, y: geometry.size.height * 0.0023) // 4/852, 2/852
        }
    }
}

#Preview {
    HomeView()
}

// ===== 底部弧形形状 =====
struct BottomCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // 从左上角开始
        path.move(to: CGPoint(x: 0, y: 0))

        // 画右上角
        path.addLine(to: CGPoint(x: width, y: 0))

        // 画右边线到弧形开始处
        // 两边底部：416/450 = 0.924
        let sideY: CGFloat = height * 0.924
        path.addLine(to: CGPoint(x: width, y: sideY))

        // 画底部的弧形曲线
        // 两边底部：416，中间底部：434
        // 对于二次贝塞尔曲线，在t=0.5时：y_mid = 0.5 * (y_start + y_end) + 0.5 * y_control
        // 434 = 0.5 * 416 + 0.5 * y_control
        // y_control = 452
        // 控制点：452/450 = 1.004
        let controlY: CGFloat = height * 1.004
        path.addQuadCurve(
            to: CGPoint(x: 0, y: sideY),
            control: CGPoint(x: width / 2, y: controlY)
        )

        // 画左边线回到起点
        path.addLine(to: CGPoint(x: 0, y: 0))

        path.closeSubpath()

        return path
    }
}
