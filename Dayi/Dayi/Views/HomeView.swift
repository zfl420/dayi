import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: PeriodViewModel
    @State private var shouldAnimateWeekCalendar: Bool = true

    init(viewModel: PeriodViewModel = PeriodViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                            .font(.system(size: geometry.size.height * 0.0188, weight: .medium)) // 16/852
                            .foregroundColor(.black)
                            .padding(.top, geometry.size.height * 0.105) // 增加顶部间距，整体下移

                        // ===== 周历 =====
                        WeekCalendar(
                            viewModel: viewModel,
                            geometry: geometry,
                            isTodayInPeriod: viewModel.isSelectedDateInPeriodForBackground,
                            shouldAnimateSelection: $shouldAnimateWeekCalendar
                        )
                        .padding(.top, geometry.size.height * 0.0235) // 20/852

                        // ===== 经期状态区域和按钮层叠区域 =====
                        ZStack(alignment: .center) {
                            // ===== 经期状态区域（包含整个可滑动区域）=====
                            PeriodStatusCarousel(
                                viewModel: viewModel,
                                geometry: geometry,
                                shouldAnimateWeekCalendar: $shouldAnimateWeekCalendar
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, geometry.size.height * 0.018) // 经期状态区域顶部间距
                            .padding(.bottom, geometry.size.height * 0.1) // 经期状态区域下间距

                            // ===== 按钮区域 =====
                            VStack {
                                Spacer()
                                EditButton(viewModel: viewModel, geometry: geometry, isSelectedDateInPeriod: viewModel.isSelectedDateInPeriod)
                                    .padding(.bottom, geometry.size.height * 0.036) // 按钮与弧形中间的间距
                                    .allowsHitTesting(true) // 确保按钮可点击
                            }
                        }
                        .frame(height: geometry.size.height * 0.3628) // ZStack固定高度
                    }
                    .background(
                        // ===== 渐变背景直接作为内容背景，自动适应高度 =====
                        GradientBackground(geometry: geometry, isTodayInPeriod: viewModel.isSelectedDateInPeriodForBackground)
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

// ===== 经期状态轮播组件 =====
struct PeriodStatusCarousel: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy
    @Binding var shouldAnimateWeekCalendar: Bool
    @State private var offset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var baseDate: Date = Date()

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
                    }
                    .onEnded { value in
                        let threshold = width * 0.3 // 滑动阈值：30%

                        if dragOffset > threshold {
                            // 向右滑动，切换到前一天
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = width
                            }

                            // 先禁用周历动画
                            shouldAnimateWeekCalendar = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let previousDate = baseDate.adding(days: -1)
                                // 先重置状态
                                baseDate = previousDate
                                offset = 0
                                dragOffset = 0
                                // 更新选中日期（此时不会触发周历动画）
                                viewModel.selectDate(previousDate)
                                viewModel.updateWeekDates(for: previousDate)

                                // 延迟重新启用周历动画
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    shouldAnimateWeekCalendar = true
                                }
                            }
                        } else if dragOffset < -threshold {
                            // 向左滑动，切换到后一天
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = -width
                            }

                            // 先禁用周历动画
                            shouldAnimateWeekCalendar = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let nextDate = baseDate.adding(days: 1)
                                // 先重置状态
                                baseDate = nextDate
                                offset = 0
                                dragOffset = 0
                                // 更新选中日期（此时不会触发周历动画）
                                viewModel.selectDate(nextDate)
                                viewModel.updateWeekDates(for: nextDate)

                                // 延迟重新启用周历动画
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    shouldAnimateWeekCalendar = true
                                }
                            }
                        } else {
                            // 未达到阈值，回弹到当前页
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
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
            // 只有在启用动画时才更新，避免冲突
            if baseDate != newValue && shouldAnimateWeekCalendar {
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
