import SwiftUI

/// 日历页空状态
struct CalendarEmptyState: View {
    @ObservedObject var viewModel: PeriodViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: geometry.size.height * 0.02) {
            Text("记录你上一次经期开始的日期")
                .font(.pingFang(size: geometry.size.height * 0.0211, weight: .medium))
                .foregroundColor(Color("Hex111827"))

            NavigationLink(destination: DatePickerFullScreenContent(viewModel: viewModel)) {
                Text("记录月经")
                    .font(.pingFang(size: geometry.size.height * 0.0188, weight: .bold))
                    .foregroundColor(Color("HexFEFFFF"))
                    .frame(height: geometry.size.height * 0.0468)
                    .padding(.horizontal, geometry.size.width * 0.0407)
                    .background(Color("HexFF678B"))
                    .cornerRadius(geometry.size.height * 0.0234)
                    .blur(radius: geometry.size.height * 0.0003)
                    .shadow(
                        color: Color("Hex111827").opacity(0.02),
                        radius: geometry.size.height * 0.0047,
                        x: 0,
                        y: geometry.size.height * 0.0023
                    )
            }
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.openDatePicker()
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pageBackground)
    }
}
