import SwiftUI

struct EditPeriodSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PeriodViewModel

    @State private var endDate: Date?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let record = viewModel.currentPeriodRecord {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("编辑月经日期")
                            .font(.headline)
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("开始日期")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(record.startDate.monthDayString)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)

                        if record.isOngoing {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("结束日期(可选)")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                DatePicker(
                                    "选择结束日期",
                                    selection: Binding(
                                        get: { endDate ?? Date() },
                                        set: { endDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .frame(height: 300)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("结束日期")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text((record.endDate ?? record.startDate).monthDayString)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
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

                        if record.isOngoing {
                            Button(action: {
                                if let endDate = endDate {
                                    viewModel.updatePeriodEndDate(recordId: record.id, endDate: endDate)
                                }
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
                        } else {
                            Button(action: { dismiss() }) {
                                Text("关闭")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.appPurple)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
