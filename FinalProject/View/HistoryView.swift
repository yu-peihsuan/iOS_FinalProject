import SwiftUI

struct HistoryView: View {
    @Environment(FavoritesStore.self) private var store
    @State private var showClearConfirm = false

    private let warm = Color(red: 0.55, green: 0.42, blue: 0.32)
    private let sand = Color(red: 0.82, green: 0.76, blue: 0.68)

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.92).ignoresSafeArea()

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
            Image(systemName: "clock")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(warm)
            Text("還沒有抽選紀錄")
                .font(.system(size: 18, weight: .light))
            Text("去轉一次轉盤，紀錄就會出現在這裡")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(warm)
            .tracking(1)
            .textCase(nil)
    }

    private func historyRow(_ record: SpinRecord) -> some View {
        HStack(spacing: 12) {
            Text(record.restaurant.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(sand.opacity(0.4))
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
