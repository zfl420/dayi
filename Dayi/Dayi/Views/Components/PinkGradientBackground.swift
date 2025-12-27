import SwiftUI

struct PinkGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.lightPink, Color.darkPink]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
