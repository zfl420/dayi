import SwiftUI

struct DayCell: View {
    let date: Date
    let state: DateState
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            // 主圆形背景
            VStack(spacing: geometry.size.height * 0.0023) { // 2/852
                Text(date.shortDateString)
                    .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                    .foregroundColor(textColor)

                if isToday {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .frame(width: geometry.size.height * 0.0047, height: geometry.size.height * 0.0047) // 4/852
                }
            }
            .frame(width: cellSize, height: cellSize)
            .background(backgroundColor)
            .clipShape(Circle())
        }
        .frame(width: cellSize, height: cellSize)
    }

    private var fontSize: CGFloat {
        return geometry.size.height * 0.0229 // 19.5/852 (所有日期统一字号)
    }

    private var cellSize: CGFloat {
        return geometry.size.width * 0.1272 // 50/393 (所有日期统一大小)
    }

    private var isToday: Bool {
        date.isSameDay(as: Date())
    }

    private var backgroundColor: Color {
        switch state {
        case .selected:
            return Color(red: 220/255.0, green: 213/255.0, blue: 210/255.0) // #DCD5D2
        default:
            return .clear
        }
    }

    private var textColor: Color {
        switch state {
        case .selected:
            return Color(red: 0.0, green: 0.0, blue: 0.0)
        default:
            return Color(red: 0.0, green: 0.0, blue: 0.0)
        }
    }

    private var fontWeight: Font.Weight {
        // 今天始终粗体，其他都是常规
        if isToday {
            return .semibold
        } else {
            return .regular
        }
    }
}
