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

                // ===== 上半部分渐变背景 =====
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 247/255.0, green: 240/255.0, blue: 238/255.0), location: 0.0),
                            .init(color: Color(red: 254/255.0, green: 255/255.0, blue: 254/255.0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: calculateGradientHeight(geometry: geometry))
                    .clipShape(BottomCurveShape())

                    Spacer()
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ===== 日期标题 =====
                    Text(viewModel.displayDateText)
                        .font(.system(size: geometry.size.height * 0.0188, weight: .medium)) // 16/852
                        .foregroundColor(.black)
                        .padding(.top, geometry.size.height * 0.088) // 75/852

                    // ===== 周历 =====
                    WeekCalendar(viewModel: viewModel, geometry: geometry)
                        .padding(.top, geometry.size.height * 0.0235) // 20/852

                    // ===== 经期状态 =====
                    PeriodStatus(viewModel: viewModel, geometry: geometry)
                        .padding(.top, geometry.size.height * 0.11) // 93.72/852, 向上移动

                    // ===== 编辑按钮 =====
                    EditButton(viewModel: viewModel, geometry: geometry)
                        .padding(.top, geometry.size.height * 0.038) // 32.376/852, 向上移动

                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
    }

    private func calculateGradientHeight(geometry: GeometryProxy) -> CGFloat {
        // 中间底部距离顶部：434
        // 需要确保渐变区域高度至少为434，以包含整个圆弧
        // 增加一些额外空间以确保圆弧完整显示
        return geometry.size.height * 0.528 // 450/852
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

    var body: some View {
        Button(action: {
            // 弹窗已删除
        }) {
            Text("记录月经")
                .font(.system(size: geometry.size.height * 0.0188, weight: .bold)) // 16/852, 增大字号并加粗
                .foregroundColor(.white)
                .padding(.horizontal, geometry.size.width * 0.0407) // 16/393, 左右边距减半
                .frame(height: geometry.size.height * 0.0468) // 39.84/852, 介于44和35.78之间
                .background(Color(red: 255.0/255.0, green: 90.0/255.0, blue: 125.0/255.0))
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
