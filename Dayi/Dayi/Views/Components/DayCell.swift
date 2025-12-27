import SwiftUI

struct DayCell: View {
    let date: Date
    let state: DateState

    var body: some View {
        VStack(spacing: 0) {
            Text(date.shortDateString)
                .font(.system(size: 13, weight: fontWeight))
                .foregroundColor(textColor)
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(borderOverlay)
    }

    private var backgroundColor: Color {
        switch state {
        case .selected, .actualAndSelected, .predictedAndSelected:
            return .white
        case .actualPeriod:
            return .periodRed
        default:
            return .clear
        }
    }

    private var textColor: Color {
        switch state {
        case .selected, .actualAndSelected, .predictedAndSelected:
            return .black
        case .actualPeriod:
            return .white
        default:
            return .gray.opacity(0.6)
        }
    }

    private var fontWeight: Font.Weight {
        switch state {
        case .selected, .actualPeriod, .actualAndSelected, .predictedAndSelected:
            return .semibold
        default:
            return .regular
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if case .predictedPeriod = state {
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                .foregroundColor(.periodRed)
        } else if case .predictedAndSelected = state {
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                .foregroundColor(.periodRed)
        }
    }
}
