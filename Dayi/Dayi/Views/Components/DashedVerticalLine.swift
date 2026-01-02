import SwiftUI

/// 虚线参考线组件
struct DashedVerticalLine: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let dashLength: CGFloat = 3
                let gapLength: CGFloat = 2
                var currentY: CGFloat = 0

                while currentY < geometry.size.height {
                    path.move(to: CGPoint(x: 0, y: currentY))
                    path.addLine(to: CGPoint(x: 0, y: min(currentY + dashLength, geometry.size.height)))
                    currentY += dashLength + gapLength
                }
            }
            .stroke(color, lineWidth: 1)
        }
    }
}
