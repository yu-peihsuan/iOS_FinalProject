import SwiftUI

struct ContentView: View {

    @State private var selectedMeal = "晚餐"
    @State private var selectedCategories: Set<String> = ["日式"]
    @State private var maxPriceLevel: Int = 2
    @State private var distance: Double = 3

    private let meals = ["早餐", "午餐", "晚餐", "點心"]
    private let categories: [(name: String, emoji: String)] = [
        ("日式", "🍱"), ("台式", "🥢"),
        ("韓式", "🌶️"), ("美式", "🍔"),
        ("義式", "🍝"), ("火鍋", "🫕"),
        ("拉麵", "🍜"), ("手搖飲", "🧋"),
        ("港式", "🥠"), ("泰式", "🍛"),
        ("素食", "🥗"), ("甜點", "🧁")
    ]
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    var body: some View {

        NavigationStack {

            ZStack {

                Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 16) {

                        headerSection
                        mealSection
                        categorySection
                        filterSection
                        spinButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Sections

extension ContentView {

    private var headerSection: some View {

        ZStack(alignment: .top) {

            VStack(spacing: 8) {

                Text("🍽️")
                    .font(.system(size: 64))
                    .padding(.top, 32)

                Text("今天吃什麼？")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("設定你的偏好，讓系統幫你決定！")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.bottom, 4)

            HStack {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24))
                        .foregroundStyle(accent)
                        .padding(.top, 8)
                }

                Spacer()

                NavigationLink(destination: FavoritesView()) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(accent)
                        .padding(.top, 8)
                }
            }
        }
    }

    private var mealSection: some View {

        VStack(alignment: .leading, spacing: 14) {

            Label("用餐時段", systemImage: "clock.fill")
                .font(.headline)
                .foregroundStyle(accent)

            HStack(spacing: 8) {

                ForEach(meals, id: \.self) { meal in

                    Button {
                        selectedMeal = meal
                    } label: {
                        Text(meal)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedMeal == meal
                                ? accent
                                : Color.gray.opacity(0.08)
                            )
                            .foregroundStyle(
                                selectedMeal == meal ? .white : .primary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var categorySection: some View {

        VStack(alignment: .leading, spacing: 14) {

            HStack {

                Label("食物類別", systemImage: "fork.knife")
                    .font(.headline)
                    .foregroundStyle(accent)

                Spacer()

                Text("可多選")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(Capsule())
            }

            LazyVGrid(columns: columns, spacing: 10) {

                ForEach(categories, id: \.name) { category in

                    let isSelected = selectedCategories.contains(category.name)

                    Button {
                        if isSelected {
                            if selectedCategories.count > 1 {
                                selectedCategories.remove(category.name)
                            }
                        } else {
                            selectedCategories.insert(category.name)
                        }
                    } label: {
                        HStack(spacing: 8) {

                            Text(category.emoji)
                                .font(.title3)

                            Text(category.name)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.callout)
                                .foregroundStyle(isSelected ? accent : Color.gray.opacity(0.4))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(isSelected ? accent.opacity(0.1) : Color.gray.opacity(0.05))
                        .foregroundStyle(isSelected ? accent : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isSelected ? accent.opacity(0.45) : Color.clear,
                                    lineWidth: 1.5
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var filterSection: some View {

        VStack(alignment: .leading, spacing: 20) {

            Label("進階篩選", systemImage: "slider.horizontal.3")
                .font(.headline)
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 10) {

                HStack {

                    Text("搜尋距離")
                        .font(.subheadline)

                    Spacer()

                    Text("\(Int(distance)) 公里")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                        .monospacedDigit()
                }

                Slider(value: $distance, in: 1...10, step: 1)
                    .tint(accent)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Text("預算上限")
                        .font(.subheadline)

                    Spacer()

                    Text(priceLevelLabel(maxPriceLevel))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                }

                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { level in
                        Button {
                            maxPriceLevel = level
                        } label: {
                            Text(String(repeating: "$", count: level))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    level <= maxPriceLevel
                                    ? accent
                                    : Color.gray.opacity(0.08)
                                )
                                .foregroundStyle(
                                    level <= maxPriceLevel ? .white : .primary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var spinButton: some View {

        NavigationLink(destination: WheelView(selectedCategories: selectedCategories, selectedMeal: selectedMeal, maxPriceLevel: maxPriceLevel, maxDistance: distance)) {

            HStack(spacing: 10) {

                Image(systemName: "sparkles")
                    .font(.title3)

                Text("開始幫我選！")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        accent,
                        Color(red: 0.85, green: 0.22, blue: 0.35)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: accent.opacity(0.45), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func priceLevelLabel(_ level: Int) -> String {
        switch level {
        case 1: return "$ 平價"
        case 2: return "$$ 中等"
        case 3: return "$$$ 偏貴"
        case 4: return "$$$$ 高價"
        default: return ""
        }
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
}
