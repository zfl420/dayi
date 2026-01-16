import SwiftUI

extension Font {
    static func pingFang(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom("PingFang SC", size: size).weight(weight)
    }
}
