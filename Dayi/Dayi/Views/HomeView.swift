import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: PeriodViewModel
    @State private var dragProgress: CGFloat = 0 // 滑动进度 -1 到 1
    @State private var isDragging: Bool = false // 是否正在滑动
    @State private var carouselBaseDate: Date = Date() // 轮播组件的基准日期
    @State private var periodRatio: CGFloat = 0 // 背景色的经期比例（0 = 非经期，1 = 经期）
    @State private var buttonRatio: CGFloat = 0 // 按钮过渡比例

    init(viewModel: PeriodViewModel = PeriodViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // 计算目标的经期比例
    private func calculatePeriodRatio() -> CGFloat {
        // 使用轮播组件的基准日期来判断当前状态
        let currentInPeriod = viewModel.getDateStatus(for: carouselBaseDate).isInPeriod

        if !isDragging || dragProgress == 0 {
            return currentInPeriod ? 1 : 0
        }

        // 计算目标日期是否在经期
        let targetDate: Date
        if dragProgress > 0 {
            // 向右滑，目标是前一天
            targetDate = carouselBaseDate.adding(days: -1)
        } else {
            // 向左滑，目标是后一天
            targetDate = carouselBaseDate.adding(days: 1)
        }

        let targetInPeriod = viewModel.getDateStatus(for: targetDate).isInPeriod

        // 根据滑动进度插值
        let progress = min(abs(dragProgress), 1.0)
        let currentValue: CGFloat = currentInPeriod ? 1 : 0
        let targetValue: CGFloat = targetInPeriod ? 1 : 0

        return currentValue + (targetValue - currentValue) * progress
    }

    private var mainContent: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // ===== 整体背景渐变 =====
                GradientBackground(geometry: geometry, periodRatio: periodRatio)

                VStack(spacing: 0) {
                    // ===== 上半部分区域 =====
                    VStack(spacing: 0) {
                        // ===== 日期标题 =====
                        Text(viewModel.displayDateText)
                            .font(.system(size: geometry.size.height * 0.0188, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
                            .padding(.top, geometry.size.height * 0.105)

                        // ===== 周历 =====
                        WeekCalendar(
                            viewModel: viewModel,
                            geometry: geometry,
                            isTodayInPeriod: viewModel.isSelectedDateInPeriodForBackground
                        )
                        .padding(.top, geometry.size.height * 0.0235)

                        // ===== 经期状态和按钮层叠区域 =====
                        ZStack(alignment: .center) {
                            // ===== 底层：圆形背景装饰（淡入淡出过渡）=====
                            ZStack {
                                // 非经期状态背景圆
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color(red: 254/255, green: 255/255, blue: 255/255), location: 0.0),
                                                .init(color: Color(red: 255/255, green: 235/255, blue: 239/255), location: 0.3),
                                                .init(color: Color(red: 255/255, green: 214/255, blue: 224/255), location: 1.0)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blur(radius: geometry.size.height * 0.005)
                                    .frame(width: geometry.size.height * 0.36, height: geometry.size.height * 0.36)
                                    .opacity(0.8 * (1 - periodRatio))

                                // 经期状态背景圆
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color(red: 254/255, green: 255/255, blue: 255/255), location: 0.0),
                                                .init(color: Color(red: 255/255, green: 235/255, blue: 239/255), location: 0.25),
                                                .init(color: Color(red: 255/255, green: 214/255, blue: 224/255), location: 0.5),
                                                .init(color: Color(red: 255/255, green: 103/255, blue: 139/255), location: 1.0)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blur(radius: geometry.size.height * 0.005)
                                    .frame(width: geometry.size.height * 0.36, height: geometry.size.height * 0.36)
                                    .opacity(0.8 * periodRatio)
                            }

                            // ===== 上层：状态及按钮区域 =====
                            VStack(spacing: 0) {
                                // ===== 经期状态文案 =====
                                PeriodStatusCarousel(
                                    viewModel: viewModel,
                                    geometry: geometry,
                                    dragProgress: $dragProgress,
                                    isDragging: $isDragging,
                                    baseDate: $carouselBaseDate
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.top, geometry.size.height * 0.018)

                                Spacer()

                                // ===== 编辑按钮 =====
                                EditButton(
                                    viewModel: viewModel,
                                    geometry: geometry,
                                    periodRatio: buttonRatio
                                )
                                .padding(.bottom, geometry.size.height * 0.05)
                                .allowsHitTesting(true)
                            }
                        }
                        .frame(height: geometry.size.height * 0.3628)
                        .padding(.top, geometry.size.height * 0.042) // 经期状态和按钮区域上边距
                    }

                    // 我的月经周期区域
                    MenstrualCycleInfo(
                        geometry: geometry,
                        viewModel: viewModel
                    )
                    .padding(.top, geometry.size.height * 0.042) // 我的月经周期上边距

                    Spacer()
                }
            }
            .ignoresSafeArea()
            .onAppear {
                // 初始化 periodRatio
                let ratio = calculatePeriodRatio()
                periodRatio = ratio
                buttonRatio = ratio
            }
            .onChange(of: carouselBaseDate) { oldValue, newValue in
                // carouselBaseDate 变化时，使用动画更新 periodRatio
                withAnimation(.easeOut(duration: 0.3)) {
                    periodRatio = calculatePeriodRatio()
                }
                // 按钮立即切换，不使用动画
                buttonRatio = calculatePeriodRatio()
            }
            .onChange(of: dragProgress) { oldValue, newValue in
                // dragProgress 变化时，实时更新 periodRatio（滑动时不需要动画）
                periodRatio = calculatePeriodRatio()
                if isDragging {
                    buttonRatio = periodRatio
                }
            }
            .onChange(of: isDragging) { oldValue, newValue in
                // isDragging 状态变化时，更新 periodRatio
                if !newValue {
                    // 滑动结束，使用动画过渡到最终状态
                    withAnimation(.easeOut(duration: 0.2)) {
                        periodRatio = calculatePeriodRatio()
                    }
                    // 按钮立即切换，不使用动画
                    buttonRatio = calculatePeriodRatio()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .iOS16ToolbarBackgroundHidden()
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    mainContent
                }
            } else {
                NavigationView {
                    mainContent
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

// ===== 渐变背景组件 =====
struct GradientBackground: View {
    let geometry: GeometryProxy
    let periodRatio: CGFloat // 0 = 非经期，1 = 经期，中间值为过渡状态

    // 非经期渐变色
    private let normalColor1 = Color(red: 254/255, green: 255/255, blue: 255/255)
    private let normalColor2 = Color(red: 255/255, green: 247/255, blue: 249/255)
    private let normalColor3 = Color(red: 255/255, green: 185/255, blue: 205/255)

    // 经期渐变色
    private let periodColor1 = Color(red: 254/255, green: 255/255, blue: 255/255)
    private let periodColor2 = Color(red: 255/255, green: 247/255, blue: 249/255)
    private let periodColor3 = Color(red: 255/255, green: 227/255, blue: 235/255)
    private let periodColor4 = Color(red: 255/255, green: 168/255, blue: 188/255)

    // 根据 periodRatio 插值计算各个渐变点的颜色
    private var gradientStops: [Gradient.Stop] {
        if periodRatio < 0.5 {
            // 非经期主导，使用3个色点
            let color1 = normalColor1
            let color2 = normalColor2
            let color3 = normalColor3

            return [
                .init(color: color1, location: 0.0),
                .init(color: color2, location: 0.5),
                .init(color: color3, location: 1.0)
            ]
        } else {
            // 经期主导，使用4个色点
            let color1 = periodColor1
            let color2 = periodColor2
            let color3 = periodColor3
            let color4 = periodColor4

            return [
                .init(color: color1, location: 0.0),
                .init(color: color2, location: 0.3),
                .init(color: color3, location: 0.6),
                .init(color: color4, location: 1.0)
            ]
        }
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: gradientStops),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// ===== 经期状态轮播组件 =====
struct PeriodStatusCarousel: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    @Binding var dragProgress: CGFloat // 滑动进度，传递给父视图
    @Binding var isDragging: Bool // 是否正在滑动
    @Binding var baseDate: Date // 基准日期，传递给父视图用于计算背景色
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { scrollGeometry in
            let width = scrollGeometry.size.width

            ZStack {
                // 滑动内容
                HStack(spacing: 0) {
                    // 前一天
                    PeriodStatusPage(
                        date: baseDate.adding(days: -1),
                        viewModel: viewModel,
                        geometry: geometry
                    )
                    .frame(width: width)

                    // 当前日期
                    PeriodStatusPage(
                        date: baseDate,
                        viewModel: viewModel,
                        geometry: geometry
                    )
                    .frame(width: width)

                    // 后一天
                    PeriodStatusPage(
                        date: baseDate.adding(days: 1),
                        viewModel: viewModel,
                        geometry: geometry
                    )
                    .frame(width: width)
                }
                .offset(x: -width + offset + dragOffset) // 默认显示中间页
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 填充整个区域
            .contentShape(Rectangle()) // 让整个区域可响应手势
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                        isDragging = true
                        // 更新滑动进度（归一化到 -1 到 1）
                        dragProgress = dragOffset / width
                    }
                    .onEnded { value in
                        let threshold = width * 0.15 // 滑动阈值：15%

                        if dragOffset > threshold {
                            // 向右滑动，切换到前一天
                            let previousDate = baseDate.adding(days: -1)

                            // 先平滑完成滑入动画
                            withAnimation(.easeOut(duration: 0.25)) {
                                offset = width
                                dragOffset = 0
                            }

                            // 动画完成后更新状态
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                baseDate = previousDate
                                offset = 0
                                dragProgress = 0
                                isDragging = false

                                // 更新选中日期，触发周历动画
                                viewModel.selectDate(previousDate)
                                viewModel.updateWeekDates(for: previousDate)
                            }

                        } else if dragOffset < -threshold {
                            // 向左滑动，切换到后一天
                            let nextDate = baseDate.adding(days: 1)

                            // 先平滑完成滑入动画
                            withAnimation(.easeOut(duration: 0.25)) {
                                offset = -width
                                dragOffset = 0
                            }

                            // 动画完成后更新状态
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                baseDate = nextDate
                                offset = 0
                                dragProgress = 0
                                isDragging = false

                                // 更新选中日期，触发周历动画
                                viewModel.selectDate(nextDate)
                                viewModel.updateWeekDates(for: nextDate)
                            }

                        } else {
                            // 未达到阈值，回弹到当前页
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                                dragProgress = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isDragging = false
                            }
                        }
                    }
            )
        }
        .onAppear {
            baseDate = viewModel.selectedDate
        }
        .onChange(of: viewModel.selectedDate) { oldValue, newValue in
            // 外部改变日期时更新 baseDate（比如点击周历）
            if baseDate != newValue {
                // 延迟更新，等待周历动画完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    baseDate = newValue
                }
            }
        }
    }
}

// ===== 经期状态单页组件 =====
struct PeriodStatusPage: View {
    let date: Date
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Spacer() // 上方填充

            PeriodStatus(date: date, viewModel: viewModel, geometry: geometry)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer() // 下方填充
        }
    }
}

// ===== 经期状态组件 =====
struct PeriodStatus: View {
    let date: Date
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: geometry.size.height * 0.0047) { // 文案行间距
            // 根据传入的日期计算状态
            let status = viewModel.getDateStatus(for: date)

            switch status {
            case .beforeAllPeriods:
                // 情况1：单行文本
                titleText("记录你上一次经期开始的日期")

            case .inPeriod(let dayNumber):
                // 情况2：经期内 - 双行布局
                titleText("经期")
                dayText("第 \(dayNumber) 天")

            case .afterPeriod(let daysSince):
                // 情况3：经期后 - 双行布局
                titleText("过去的月经周期")
                dayText("第 \(daysSince) 天")
            }
        }
    }

    // 标题文字样式
    private func titleText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: geometry.size.height * 0.022, weight: .bold, design: .rounded)) // 标题字号
            .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
    }

    // 天数文字样式
    private func dayText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: geometry.size.height * 0.054, weight: .bold, design: .rounded)) // 天数字号
            .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
    }
}

// ===== 编辑按钮组件（淡入淡出过渡）=====
struct EditButton: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let periodRatio: CGFloat // 0 = 非经期，1 = 经期

    var body: some View {
        ZStack {
            // 非经期按钮（淡出）
            NavigationLink(destination: DatePickerFullScreenContent(viewModel: viewModel)) {
                Text("记录月经")
                    .font(.system(size: geometry.size.height * 0.0188, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, geometry.size.width * 0.0407)
                    .frame(height: geometry.size.height * 0.0468)
                    .background(Color(red: 255/255, green: 90/255, blue: 125/255))
                    .cornerRadius(geometry.size.height * 0.0234)
                    .blur(radius: geometry.size.height * 0.0003)
                    .shadow(color: Color.black.opacity(0.02), radius: geometry.size.height * 0.0047, x: 0, y: geometry.size.height * 0.0023)
            }
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.openDatePicker()
            })
            .opacity(1 - periodRatio)

            // 经期按钮（淡入）
            NavigationLink(destination: DatePickerFullScreenContent(viewModel: viewModel)) {
                Text("编辑月经日期")
                    .font(.system(size: geometry.size.height * 0.0188, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 255/255, green: 90/255, blue: 125/255))
                    .padding(.horizontal, geometry.size.width * 0.0407)
                    .frame(height: geometry.size.height * 0.0468)
                    .background(Color.white)
                    .cornerRadius(geometry.size.height * 0.0234)
                    .blur(radius: geometry.size.height * 0.0003)
                    .shadow(color: Color.black.opacity(0.02), radius: geometry.size.height * 0.0047, x: 0, y: geometry.size.height * 0.0023)
            }
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.openDatePicker()
            })
            .opacity(periodRatio)
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

/// 透明背景视图辅助器
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
