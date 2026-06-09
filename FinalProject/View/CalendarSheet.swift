import SwiftUI

struct CalendarSheet: View {
    let restaurant: Restaurant

    @State private var selectedDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var note = ""
    @State private var isAdding = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @Environment(\.dismiss) private var dismiss

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Text(restaurant.emoji)
                            .font(.system(size: 44))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("用餐日期與時間") {
                    DatePicker(
                        "選擇時間",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(accent)
                }

                Section("備註（選填）") {
                    TextField("例如：與朋友聚餐", text: $note)
                }
            }
            .navigationTitle("加入行事曆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await addEvent() }
                    } label: {
                        if isAdding {
                            ProgressView().scaleEffect(0.85)
                        } else {
                            Text("新增").fontWeight(.semibold)
                        }
                    }
                    .disabled(isAdding)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("確定") {
                    if alertTitle.contains("成功") { dismiss() }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func addEvent() async {
        isAdding = true
        do {
            try await CalendarManager.shared.addEvent(
                title: "🍽️ \(restaurant.name)",
                date: selectedDate,
                note: note.isEmpty ? nil : note
            )
            alertTitle = "加入行事曆成功 🎉"
            alertMessage = "「\(restaurant.name)」已安排在 \(formattedDate(selectedDate))。"
        } catch {
            alertTitle = "新增失敗"
            alertMessage = error.localizedDescription
        }
        isAdding = false
        showAlert = true
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "zh_TW")
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}
