import SwiftUI

struct RecordPeriodSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PeriodViewModel

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("记录月经开始日期")
                        .font(.headline)
                        .foregroundColor(.black)

                    DatePicker(
                        "选择日期",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .frame(height: 400)
                }
                .padding()

                Spacer()

                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("取消")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Button(action: {
                        viewModel.recordNewPeriod(startDate: selectedDate)
                        dismiss()
                    }) {
                        Text("确认")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.appPurple)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
