import SwiftUI
import UIKit

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

    /// 是否是被选中的未来日期
    private var isFutureSelected: Bool {
        isSelected && isFutureDate
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
        return max(checkboxSize * 0.5, 1) // 确保最小为1，避免SF Symbol报错
    }

    private var checkmarkWeight: Font.Weight {
        return .black  // 最粗的字重
    }

    // MARK: - 颜色

    private var primaryColor: Color {
        Color.datePickerAccent
    }

    /// 灰色
    private var grayColor: Color {
        Color("HexB4B4B4")
    }

    /// 日期数字颜色
    private var dateTextColor: Color {
        if isSelected {
            return primaryColor
        } else if isFutureDate && !isExtendable {
            return grayColor
        }
        return Color("Hex111827")
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
                    .font(.pingFang(size: geometry.size.height * 0.014 * 1.2, weight: .heavy))
                    .foregroundColor(isSelected ? primaryColor : Color("Hex646464"))
                    .padding(.bottom, geometry.size.height * 0.008 * 0.2)
            } else {
                // 占位，保持布局一致
                Text(" ")
                    .font(.pingFang(size: geometry.size.height * 0.014))
                    .padding(.bottom, geometry.size.height * 0.008 * 0.2)
            }

            // 日期数字
            Text(date.shortDateString)
                .font(.pingFang(size: geometry.size.height * 0.025, weight: dateFontWeight))
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
            // 选中状态：区分未来和历史日期
            if isFutureSelected {
                // 未来日期：红色虚线圆 + 红色勾
                futureSelectedCheckbox
            } else {
                // 今天或过去日期：红色实心圆 + 白色勾
                selectedCheckbox
            }
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
            .stroke(Color("HexC8C8C8"), lineWidth: 3)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    /// 选中状态（红色实心圆 + 白色勾）
    private var selectedCheckbox: some View {
        ZStack {
            Circle()
                .fill(primaryColor)
                .frame(width: checkboxSize, height: checkboxSize)

            Image(systemName: "checkmark")
                .foregroundColor(Color("HexFFFFFF"))
                .font(.pingFang(size: checkmarkSize, weight: checkmarkWeight))
        }
    }

    /// 可扩展日期（灰色圆点虚线圆）
    private var extendableCheckbox: some View {
        DottedCircle(dotCount: 12, dotRadius: 1.5)
            .foregroundColor(grayColor)
            .frame(width: checkboxSize, height: checkboxSize)
    }

    /// 未来日期选中样式（红色虚线圆 + 红色勾）
    private var futureSelectedCheckbox: some View {
        ZStack {
            // 红色虚线圆（12个点）
            DottedCircle(dotCount: 12, dotRadius: 1.5)
                .foregroundColor(primaryColor)
                .frame(width: checkboxSize, height: checkboxSize)

            // 红色勾
            Image(systemName: "checkmark")
                .foregroundColor(primaryColor)
                .font(.pingFang(size: checkmarkSize, weight: checkmarkWeight))
        }
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
