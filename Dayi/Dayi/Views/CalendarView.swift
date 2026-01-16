import SwiftUI

struct CalendarView: View {
    var body: some View {
        Color.pageBackground
            .ignoresSafeArea()
            .navigationTitle("日历")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CalendarView()
}
