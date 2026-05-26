import SwiftUI

struct HistoryView: View {
    @Environment(FavoritesStore.self) private var store
    @State private var showClearConfirm = false

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

            if store.history.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(dayGroups, id: \.title) { group in
                        Section(header: sectionHeader(group.title)) {
                            ForEach(group.records) { record in
                                historyRow(record)
                            }
                            .onDelete { offsets in
                                let globalOffsets = globalIndexSet(group: group, offsets: offsets)
                                store.removeFromHistory(at: globalOffsets)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("抽選紀錄")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !store.history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Text("清除全部")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .confirmationDialog("確定要清除所有抽選紀錄嗎？", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清除全部", role: .destructive) { store.clearHistory() }
            Button("取消", role: .cancel) {}
        }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🎰")
                .font(.system(size: 64))
            Text("還沒有抽選紀錄")
                .font(.title3)
                .fontWeight(.bold)
            Text("去轉一次轉盤，紀錄就會出現在這裡")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(accent)
            .textCase(nil)
    }

    private func historyRow(_ record: SpinRecord) -> some View {
        HStack(spacing: 12) {
            Text(record.restaurant.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.restaurant.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(record.restaurant.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(timeString(record.date))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Grouping

    private struct DayGroup {
        let title: String
        let records: [SpinRecord]
        let sortDate: Date
    }

    private var dayGroups: [DayGroup] {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "zh_TW")
        fmt.dateFormat = "M 月 d 日"

        var dict: [String: (records: [SpinRecord], date: Date)] = [:]
        for record in store.history {
            let key: String
            if cal.isDateInToday(record.date)     { key = "今天" }
            else if cal.isDateInYesterday(record.date) { key = "昨天" }
            else { key = fmt.string(from: record.date) }

            if dict[key] == nil {
                dict[key] = ([], record.date)
            }
            dict[key]!.records.append(record)
        }

        return dict.map { DayGroup(title: $0.key, records: $0.value.records, sortDate: $0.value.date) }
            .sorted { $0.sortDate > $1.sortDate }
    }

    private func globalIndexSet(group: DayGroup, offsets: IndexSet) -> IndexSet {
        let ids = Set(offsets.map { group.records[$0].id })
        let globalOffsets = store.history.enumerated()
            .filter { ids.contains($0.element.id) }
            .map { $0.offset }
        return IndexSet(globalOffsets)
    }

    private func timeString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "zh_TW")
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environment(FavoritesStore())
    }
}
