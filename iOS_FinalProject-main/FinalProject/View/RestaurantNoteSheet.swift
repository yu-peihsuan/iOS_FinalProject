import SwiftUI

struct RestaurantNoteSheet: View {
    @Environment(FavoritesStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let restaurant: Restaurant
    @State private var note: String

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self._note = State(initialValue: restaurant.note)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Text(restaurant.emoji)
                            .font(.system(size: 40))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("備註") {
                    TextField("例如：點招牌餐、避開尖峰時間…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                if !note.isEmpty {
                    Section {
                        Button(role: .destructive) {
                            note = ""
                        } label: {
                            Label("清除備註", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("餐廳備註")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        store.updateNote(for: restaurant.id, note: note)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(accent)
                }
            }
        }
    }
}
