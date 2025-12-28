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
/// 新布局：上方日期数字，下方选择按钮
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

    /// 是否是今天或今天之前的日期（可选日期）
    private var isPastOrToday: Bool {
        date.startOfDay() <= today
    }

    /// 是否是未来日期
    private var isFutureDate: Bool {
        date.startOfDay() > today
    }

    /// 是否在预测范围内（选中日期后的天数）
    private var isInPredictionRange: Bool {
        switch state {
        case .afterPeriodDashed, .extended:
            return true
        default:
            return false
        }
    }

    /// 是否被选中
    private var isSelected: Bool {
        if case .selected = state {
            return true
        }
        return false
    }

    /// 是否是可扩展日期（今天之后，灰色虚线框）
    private var isExtendable: Bool {
        if case .extendable = state {
            return true
        }
        return false
    }

    /// 是否是可扩展日期（今天及之前，灰色实线框）
    private var isExtendablePast: Bool {
        if case .extendablePast = state {
            return true
        }
        return false
    }

    /// 是否是任意可扩展日期
    private var isAnyExtendable: Bool {
        return isExtendable || isExtendablePast
    }

    /// 是否是已扩展日期
    private var isExtended: Bool {
        if case .extended = state {
            return true
        }
        return false
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
        return .black  // 最粗的字重，约为原来的2倍
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
        if isSelected || isInPredictionRange || isExtended {
            return primaryColor
        } else if isExtendable {
            // 今天之后的可扩展日期：灰色
            return grayColor
        } else if isFutureDate {
            return grayColor
        }
        // 今天及之前的可扩展日期（isExtendablePast）和普通日期：黑色
        return .black
    }

    /// 日期字重
    private var dateFontWeight: Font.Weight {
        if isSelected || isInPredictionRange || isExtended || isToday {
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
                    .padding(.bottom, geometry.size.height * 0.008 * 0.2)  // 缩小到1/5
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
                .padding(.bottom, geometry.size.height * 0.008 * 0.2)  // 日期与选择框间距缩小到1/5

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
        if isSelected || isInPredictionRange {
            // 选中日期或预测期内的日期
            if isPastOrToday {
                // 今天及之前：红色实心圆 + 白色勾
                selectedCheckbox
            } else {
                // 今天之后：红色虚线圆 + 红色勾
                predictionCheckbox
            }
        } else if isExtendable {
            // 可扩展日期（今天之后）：灰色虚线圆（无勾）
            extendableDashedCheckbox
        } else if isExtendablePast || isPastOrToday {
            // 今天及之前的普通日期：灰色空心圆
            unselectedCheckbox
        } else {
            // 更远的未来：不显示任何内容，但保留空间
            Color.clear
                .frame(width: checkboxSize, height: checkboxSize)
        }
    }

    /// 未选中的选择按钮（灰色空心圆）
    private var unselectedCheckbox: some View {
        Circle()
            .stroke(Color(red: 200/255.0, green: 200/255.0, blue: 200/255.0), lineWidth: 3)  // 边框粗度增加到1.5倍
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

    /// 预测期状态（红色圆点虚线圆 + 红色勾）
    private var predictionCheckbox: some View {
        ZStack {
            DottedCircle(dotCount: 12, dotRadius: 1.5)
                .foregroundColor(primaryColor)
                .frame(width: checkboxSize, height: checkboxSize)

            Image(systemName: "checkmark")
                .foregroundColor(primaryColor)
                .font(.system(size: checkmarkSize, weight: checkmarkWeight))
        }
    }

    /// 可扩展状态 - 今天之后（灰色圆点虚线圆，无勾）
    private var extendableDashedCheckbox: some View {
        DottedCircle(dotCount: 16, dotRadius: 1.5)
            .foregroundColor(grayColor)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    /// 可扩展状态 - 今天及之前（灰色实线圆，无勾）
    private var extendableSolidCheckbox: some View {
        Circle()
            .stroke(grayColor, lineWidth: 2)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    // MARK: - 点击处理

    private func handleTap() {
        // 可扩展日期被点击：扩展经期
        if isAnyExtendable {
            viewModel.extendPeriodByOneDay()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }

        // 只有今天及之前的日期可以点击选择
        if isPastOrToday {
            viewModel.updateTempDate(date)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
