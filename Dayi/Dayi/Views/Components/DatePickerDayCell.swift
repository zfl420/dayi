import SwiftUI
import UIKit

/// 日期选择器中的单个日期单元格
struct DatePickerDayCell: View {
    @ObservedObject var viewModel: PeriodViewModel
    let date: Date
    let geometry: GeometryProxy

    private var state: DateState {
        viewModel.getStateForDatePicker(date)
    }

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var isDisabled: Bool {
        if case .disabled = state {
            return true
        }
        return false
    }

    private var cellSize: CGFloat {
        return geometry.size.width * 0.12  // 约46pt
    }

    private var textColor: Color {
        switch state {
        case .selected:
            return .white
        case .disabled:
            return Color(red: 150/255.0, green: 150/255.0, blue: 150/255.0)
        case .afterPeriodDashed:
            // 如果是今天之后的日期，显示灰色；否则显示黑色
            if date.startOfDay() > Date().startOfDay() {
                return Color(red: 150/255.0, green: 150/255.0, blue: 150/255.0)
            } else {
                return .black
            }
        default:
            return .black
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .selected:
            return Color(red: 1.0, green: 90/255.0, blue: 125/255.0)
        default:
            return .clear
        }
    }

    private var borderOverlay: some View {
        Group {
            if case .normal = state {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            } else if case .afterPeriodDashed = state {
                Circle()
                    .stroke(
                        style: StrokeStyle(lineWidth: 4.5, dash: [9, 6])
                    )
                    .foregroundColor(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
            } else if case .disabled = state {
                Circle()
                    .stroke(Color(red: 200/255.0, green: 200/255.0, blue: 200/255.0), lineWidth: 1)
            }
        }
    }

    private var fontWeight: Font.Weight {
        switch state {
        case .selected:
            return .semibold
        default:
            return .regular
        }
    }

    var body: some View {
        ZStack {
            // 白色圆形背景
            Circle()
                .fill(Color.white)
                .frame(width: cellSize, height: cellSize)

            // 选中状态的背景色
            if case .selected = state {
                Circle()
                    .fill(Color(red: 1.0, green: 90/255.0, blue: 125/255.0))
                    .frame(width: cellSize, height: cellSize)
            }

            // 边框
            borderOverlay

            // 文字内容
            VStack(spacing: geometry.size.height * 0.002) {
                Text(date.shortDateString)
                    .font(.system(size: geometry.size.height * 0.0229, weight: fontWeight))
                    .foregroundColor(textColor)

                if isToday {
                    Text("今天")
                        .font(.system(size: geometry.size.height * 0.014, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .opacity(isDisabled ? 0.5 : 1.0)
        .onTapGesture {
            if !isDisabled {
                viewModel.updateTempDate(date)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}
