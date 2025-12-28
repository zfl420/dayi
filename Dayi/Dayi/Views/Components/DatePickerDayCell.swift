import SwiftUI
import UIKit

/// 圆点虚线圆形
struct DottedCircle: Shape {
    let dotCount: Int
    let dotRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - dotRadius

        for i in 0..<dotCount {
            let angle = (CGFloat(i) / CGFloat(dotCount)) * 2 * .pi - .pi / 2
            let dotCenter = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            path.addEllipse(in: CGRect(
                x: dotCenter.x - dotRadius,
                y: dotCenter.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            ))
        }

        return path
    }
}

/// 日期选择器中的单个日期单元格
struct DatePickerDayCell: View {
    @ObservedObject var viewModel: PeriodViewModel
    let date: Date
    let geometry: GeometryProxy

    // MARK: - 计算属性

    private var state: DateState {
        viewModel.getStateForDatePicker(date)
    }

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var today: Date {
        Date().startOfDay()
    }

    /// 是否是今天或今天之前的日期
    private var isPastOrToday: Bool {
        date.startOfDay() <= today
    }

    /// 是否是未来日期
    private var isFutureDate: Bool {
        date.startOfDay() > today
    }

    /// 是否被选中
    private var isSelected: Bool {
        state == .selected
    }

    /// 是否是可扩展日期
    private var isExtendable: Bool {
        state == .extendable
    }

    // MARK: - 尺寸

    private var cellWidth: CGFloat {
        return geometry.size.width * 0.12
    }

    private var cellHeight: CGFloat {
        return geometry.size.height * 0.09
    }

    private var checkboxSize: CGFloat {
        return geometry.size.width * 0.075 * 0.8  // 缩小到80%
    }

    private var checkmarkSize: CGFloat {
        return checkboxSize * 0.5
    }

    private var checkmarkWeight: Font.Weight {
        return .black  // 最粗的字重
    }

    // MARK: - 颜色

    private var primaryColor: Color {
        Color(red: 1.0, green: 90/255.0, blue: 125/255.0)
    }

    /// 灰色
    private var grayColor: Color {
        Color(red: 180/255.0, green: 180/255.0, blue: 180/255.0)
    }

    /// 日期数字颜色
    private var dateTextColor: Color {
        if isSelected {
            return primaryColor
        } else if isFutureDate && !isExtendable {
            return grayColor
        }
        return .black
    }

    /// 日期字重
    private var dateFontWeight: Font.Weight {
        if isSelected || isToday {
            return .semibold
        }
        return .regular
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 今天标签
            if isToday {
                Text("今天")
                    .font(.system(size: geometry.size.height * 0.014 * 1.2, weight: .heavy))
                    .foregroundColor(isSelected ? primaryColor : Color(red: 100/255.0, green: 100/255.0, blue: 100/255.0))
                    .padding(.bottom, geometry.size.height * 0.008 * 0.2)
            } else {
                // 占位，保持布局一致
                Text(" ")
                    .font(.system(size: geometry.size.height * 0.014))
                    .padding(.bottom, geometry.size.height * 0.008 * 0.2)
            }

            // 日期数字
            Text(date.shortDateString)
                .font(.system(size: geometry.size.height * 0.025, weight: dateFontWeight))
                .foregroundColor(dateTextColor)
                .padding(.bottom, geometry.size.height * 0.008 * 0.2)

            // 选择按钮区域
            checkboxArea
        }
        .frame(width: cellWidth, height: cellHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - 选择按钮区域

    @ViewBuilder
    private var checkboxArea: some View {
        switch state {
        case .disabled:
            // 远期未来日期：不显示选择框
            Color.clear
                .frame(width: checkboxSize, height: checkboxSize)
        case .selected:
            // 选中状态：红色实心圆 + 白色勾
            selectedCheckbox
        case .extendable:
            // 可扩展日期：灰色虚线圆
            extendableCheckbox
        case .normal:
            // 未选中：灰色空心圆
            unselectedCheckbox
        }
    }

    /// 未选中的选择按钮（灰色空心圆）
    private var unselectedCheckbox: some View {
        Circle()
            .stroke(Color(red: 200/255.0, green: 200/255.0, blue: 200/255.0), lineWidth: 3)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    /// 选中状态（红色实心圆 + 白色勾）
    private var selectedCheckbox: some View {
        ZStack {
            Circle()
                .fill(primaryColor)
                .frame(width: checkboxSize, height: checkboxSize)

            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.system(size: checkmarkSize, weight: checkmarkWeight))
        }
    }

    /// 可扩展日期（灰色圆点虚线圆）
    private var extendableCheckbox: some View {
        DottedCircle(dotCount: 12, dotRadius: 1.5)
            .foregroundColor(grayColor)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    // MARK: - 点击处理

    private func handleTap() {
        // 已选中的日期可以点击（反选），包括未来日期
        if isSelected {
            viewModel.handleDateTap(date)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }

        // 可扩展日期可以点击
        if isExtendable {
            viewModel.handleDateTap(date)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }

        // 今天及之前的日期可以点击选中
        if isPastOrToday {
            viewModel.handleDateTap(date)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
