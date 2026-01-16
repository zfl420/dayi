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
                    .font(.pingFang(size: fontSize, weight: fontWeight))
                    .foregroundColor(textColor)

                if isToday {
                    Circle()
                        .fill(Color("Hex999999"))
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
            return Color("HexDCD5D2") // #DCD5D2
        default:
            return .clear
        }
    }

    private var textColor: Color {
        switch state {
        case .selected:
            return Color("Hex111827")
        default:
            return Color("Hex111827")
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
