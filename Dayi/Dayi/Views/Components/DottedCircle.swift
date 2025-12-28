import SwiftUI

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
