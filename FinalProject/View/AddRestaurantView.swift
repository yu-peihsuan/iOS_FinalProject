import SwiftUI

struct AddRestaurantView: View {
    @Environment(FavoritesStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedCategory = "台式"

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    private let categories: [(name: String, emoji: String)] = [
        ("日式", "🍱"), ("台式", "🥢"), ("韓式", "🌶️"), ("美式", "🍔"),
        ("義式", "🍝"), ("火鍋", "🫕"), ("拉麵", "🍜"), ("手搖飲", "🧋"),
        ("港式", "🥠"), ("泰式", "🍛"), ("素食", "🥗"), ("甜點", "🧁"),
    ]

    private var selectedEmoji: String {
        categories.first { $0.name == selectedCategory }?.emoji ?? "🍽️"
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("餐廳名稱") {
                    TextField("例如：鼎泰豐", text: $name)
                }

                Section("類別") {
                    Picker("選擇類別", selection: $selectedCategory) {
                        ForEach(categories, id: \.name) { c in
                            Text("\(c.emoji) \(c.name)").tag(c.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section("預覽") {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text(selectedEmoji)
                                .font(.system(size: 52))
                            Text(name.isEmpty ? "餐廳名稱" : name)
                                .font(.subheadline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                            Text(selectedCategory)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("新增餐廳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        store.addRestaurant(Restaurant(
                            name: name.trimmingCharacters(in: .whitespaces),
                            category: selectedCategory,
                            emoji: selectedEmoji
                        ))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
}
