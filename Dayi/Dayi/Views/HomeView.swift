import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: PeriodViewModel
    @State private var dragProgress: CGFloat = 0 // 滑动进度 -1 到 1
    @State private var isDragging: Bool = false // 是否正在滑动
    @State private var carouselBaseDate: Date = Date() // 轮播组件的基准日期
    @State private var periodRatio: CGFloat = 0 // 背景色的经期比例（0 = 非经期，1 = 经期）

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

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // ===== 整体背景色 =====
                Color(red: 248/255.0, green: 243/255.0, blue: 241/255.0)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ===== 渐变背景区域的内容 =====
                    VStack(spacing: 0) {
                        // ===== 日期标题 =====
                        Text(viewModel.displayDateText)
                            .font(.system(size: geometry.size.height * 0.0188, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.top, geometry.size.height * 0.105)

                        // ===== 周历 =====
                        WeekCalendar(
                            viewModel: viewModel,
                            geometry: geometry,
                            isTodayInPeriod: viewModel.isSelectedDateInPeriodForBackground
                        )
                        .padding(.top, geometry.size.height * 0.0235)

                        // ===== 经期状态区域和按钮层叠区域 =====
                        ZStack(alignment: .center) {
                            // ===== 经期状态区域（包含整个可滑动区域）=====
                            PeriodStatusCarousel(
                                viewModel: viewModel,
                                geometry: geometry,
                                dragProgress: $dragProgress,
                                isDragging: $isDragging,
                                baseDate: $carouselBaseDate
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, geometry.size.height * 0.018)
                            .padding(.bottom, geometry.size.height * 0.1)

                            // ===== 按钮区域 =====
                            VStack {
                                Spacer()
                                EditButton(viewModel: viewModel, geometry: geometry, isSelectedDateInPeriod: viewModel.isSelectedDateInPeriod)
                                    .padding(.bottom, geometry.size.height * 0.036)
                                    .allowsHitTesting(true)
                            }
                        }
                        .frame(height: geometry.size.height * 0.3628)
                    }
                    .background(
                        // ===== 渐变背景直接作为内容背景，自动适应高度 =====
                        GradientBackground(geometry: geometry, periodRatio: periodRatio)
                    )

                    // 我的月经周期区域
                    MenstrualCycleInfo(geometry: geometry)
                        .padding(.top, geometry.size.height * 0.042) //我的月经周期上边距

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
            .onAppear {
                // 初始化 periodRatio
                periodRatio = calculatePeriodRatio()
            }
            .onChange(of: carouselBaseDate) { oldValue, newValue in
                // carouselBaseDate 变化时，使用动画更新 periodRatio
                withAnimation(.easeOut(duration: 0.3)) {
                    periodRatio = calculatePeriodRatio()
                }
            }
            .onChange(of: dragProgress) { oldValue, newValue in
                // dragProgress 变化时，实时更新 periodRatio（滑动时不需要动画）
                periodRatio = calculatePeriodRatio()
            }
            .onChange(of: isDragging) { oldValue, newValue in
                // isDragging 状态变化时，更新 periodRatio
                if !newValue {
                    // 滑动结束，使用动画过渡到最终状态
                    withAnimation(.easeOut(duration: 0.2)) {
                        periodRatio = calculatePeriodRatio()
                    }
                }
            }
        }
    }
}

// ===== 渐变背景组件 =====
struct GradientBackground: View {
    let geometry: GeometryProxy
    let periodRatio: CGFloat // 0 = 非经期，1 = 经期，中间值为过渡状态

    // 经期渐变色
    private let periodTopColor = (r: 254.0/255, g: 229.0/255, b: 234.0/255)  // #FEE5EA
    private let periodBottomColor = (r: 255.0/255, g: 90.0/255, b: 125.0/255)   // #FF5A7D

    // 非经期渐变色
    private let normalTopColor = (r: 243.0/255, g: 233.0/255, b: 230.0/255)  // #F3E9E6
    private let normalBottomColor = (r: 254.0/255, g: 255.0/255, b: 254.0/255)  // #FEFDFD

    // 根据 periodRatio 插值计算当前颜色
    private var currentTopColor: Color {
        Color(
            red: normalTopColor.r + (periodTopColor.r - normalTopColor.r) * periodRatio,
            green: normalTopColor.g + (periodTopColor.g - normalTopColor.g) * periodRatio,
            blue: normalTopColor.b + (periodTopColor.b - normalTopColor.b) * periodRatio
        )
    }

    private var currentBottomColor: Color {
        Color(
            red: normalBottomColor.r + (periodBottomColor.r - normalBottomColor.r) * periodRatio,
            green: normalBottomColor.g + (periodBottomColor.g - normalBottomColor.g) * periodRatio,
            blue: normalBottomColor.b + (periodBottomColor.b - normalBottomColor.b) * periodRatio
        )
    }

    var body: some View {
        GeometryReader { backgroundGeometry in
            let contentHeight = backgroundGeometry.size.height
            let extraHeight = geometry.size.height * 0.035
            let totalHeight = contentHeight + extraHeight

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: currentTopColor, location: 0.0),
                    .init(color: currentBottomColor, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: totalHeight)
            .clipShape(BottomCurveShape())
        }
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

                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = width
                                dragProgress = 1.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // 使用 transaction 禁用隐式动画，避免时间戳冲突
                                var transaction = Transaction()
                                transaction.disablesAnimations = true

                                withTransaction(transaction) {
                                    // 先更新基准日期，这样 periodRatio 计算时使用的是新日期
                                    baseDate = previousDate

                                    // 然后重置滑动状态
                                    isDragging = false
                                    dragProgress = 0
                                    offset = 0
                                    dragOffset = 0
                                }

                                // 更新选中日期，触发周历动画
                                viewModel.selectDate(previousDate)
                                viewModel.updateWeekDates(for: previousDate)
                            }
                        } else if dragOffset < -threshold {
                            // 向左滑动，切换到后一天
                            let nextDate = baseDate.adding(days: 1)

                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = -width
                                dragProgress = -1.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // 使用 transaction 禁用隐式动画，避免时间戳冲突
                                var transaction = Transaction()
                                transaction.disablesAnimations = true

                                withTransaction(transaction) {
                                    // 先更新基准日期，这样 periodRatio 计算时使用的是新日期
                                    baseDate = nextDate

                                    // 然后重置滑动状态
                                    isDragging = false
                                    dragProgress = 0
                                    offset = 0
                                    dragOffset = 0
                                }

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
            .font(.system(size: geometry.size.height * 0.022, weight: .bold)) // 标题字号
            .foregroundColor(.black)
    }

    // 天数文字样式
    private func dayText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: geometry.size.height * 0.054, weight: .bold)) // 天数字号
            .foregroundColor(.black)
    }
}

// ===== 编辑按钮组件 =====
struct EditButton: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    let isSelectedDateInPeriod: Bool

    var body: some View {
        Button(action: {
            viewModel.openDatePicker()
        }) {
            // 根据选中日期是否在经期选择不同的文本和颜色
            let buttonText = isSelectedDateInPeriod ? "编辑月经日期" : "记录月经"

            let textColor = isSelectedDateInPeriod
                ? Color(red: 255/255, green: 90/255, blue: 125/255)  // #FF5A7D
                : Color.white

            let backgroundColor = isSelectedDateInPeriod
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
