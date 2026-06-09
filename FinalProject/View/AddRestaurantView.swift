import SwiftUI

struct AddRestaurantView: View {
    @Environment(FavoritesStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedCategory = "台式"
    @State private var selectedPriceLevel: Int = 2
    @State private var selectedMealTypes: Set<String> = ["午餐", "晚餐"]

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)
    private let mealOptions = ["早餐", "午餐", "晚餐", "點心"]

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

                Section("價位等級") {
                    HStack(spacing: 8) {
                        ForEach(1...4, id: \.self) { level in
                            Button {
                                selectedPriceLevel = level
                            } label: {
                                Text(String(repeating: "$", count: level))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        level == selectedPriceLevel
                                        ? accent
                                        : Color.gray.opacity(0.08)
                                    )
                                    .foregroundStyle(
                                        level == selectedPriceLevel ? .white : .primary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("適合時段") {
                    HStack(spacing: 8) {
                        ForEach(mealOptions, id: \.self) { meal in
                            let isSelected = selectedMealTypes.contains(meal)
                            Button {
                                if isSelected {
                                    if selectedMealTypes.count > 1 {
                                        selectedMealTypes.remove(meal)
                                    }
                                } else {
                                    selectedMealTypes.insert(meal)
                                }
                            } label: {
                                Text(meal)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? accent.opacity(0.15) : Color.gray.opacity(0.08))
                                    .foregroundStyle(isSelected ? accent : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
                            emoji: selectedEmoji,
                            priceLevel: selectedPriceLevel,
                            mealTypes: Array(selectedMealTypes)
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
