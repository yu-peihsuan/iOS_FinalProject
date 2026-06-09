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

    private let warm = Color(red: 0.55, green: 0.42, blue: 0.32)
    private let sage = Color(red: 0.36, green: 0.50, blue: 0.38)
    private let dusty = Color(red: 0.62, green: 0.42, blue: 0.44)
    private let sand = Color(red: 0.82, green: 0.76, blue: 0.68)
    private let cream = Color(red: 0.98, green: 0.96, blue: 0.92)
    private let stone = Color(red: 0.28, green: 0.26, blue: 0.24)

    var body: some View {

        NavigationStack {

            ZStack {

                cream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 18) {

                        headerSection
                        mealSection
                        categorySection
                        filterSection
                        spinButton
                    }
                    .padding(.horizontal, 24)
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

            VStack(spacing: 12) {

                Text("今天吃什麼？")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(stone)
                    .padding(.top, 20)

            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            HStack {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(warm)
                        .padding(.top, 8)
                }

                Spacer()

                NavigationLink(destination: FavoritesView()) {
                    Image(systemName: "heart")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(dusty)
                        .padding(.top, 8)
                }
            }
        }
    }

    private var mealSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("用餐時段")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(warm)
                .tracking(2)

            HStack(spacing: 0) {

                ForEach(Array(meals.enumerated()), id: \.element) { index, meal in

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedMeal = meal
                        }
                    } label: {
                        Text(meal)
                            .font(.system(size: 16, weight: selectedMeal == meal ? .medium : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(selectedMeal == meal ? .white : stone)
                            .background(selectedMeal == meal ? warm : Color.clear)
                    }
                    .buttonStyle(.plain)

                    if index < meals.count - 1 {
                        Rectangle()
                            .fill(sand)
                            .frame(width: 1)
                            .padding(.vertical, 8)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(sand, lineWidth: 1)
            }
        }
    }

    private var categorySection: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("食物類別")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(warm)
                    .tracking(2)

                Spacer()

                Text("可複選")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(sand)
                    .tracking(1)
            }

            LazyVGrid(columns: columns, spacing: 6) {

                ForEach(categories, id: \.name) { category in

                    let isSelected = selectedCategories.contains(category.name)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected {
                                if selectedCategories.count > 1 {
                                    selectedCategories.remove(category.name)
                                }
                            } else {
                                selectedCategories.insert(category.name)
                            }
                        }
                    } label: {
                        Text(category.name)
                            .font(.system(size: 15, weight: isSelected ? .medium : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .foregroundStyle(isSelected ? .white : stone)
                            .background(isSelected ? sage : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? sage : sand, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var filterSection: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("進階篩選")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(warm)
                .tracking(2)

            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Text("搜尋距離")
                        .font(.system(size: 16))
                        .foregroundStyle(stone)

                    Spacer()

                    Text("\(Int(distance)) km")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(warm)
                        .monospacedDigit()
                }

                Slider(value: $distance, in: 1...10, step: 1)
                    .tint(warm)
            }

            Rectangle()
                .fill(sand)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Text("預算上限")
                        .font(.system(size: 16))
                        .foregroundStyle(stone)

                    Spacer()

                    Text(priceLevelLabel(maxPriceLevel))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(warm)
                }

                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { level in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                maxPriceLevel = level
                            }
                        } label: {
                            Text(String(repeating: "$", count: level))
                                .font(.system(size: 15, weight: level <= maxPriceLevel ? .medium : .regular))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundStyle(level <= maxPriceLevel ? .white : stone)
                                .background(level <= maxPriceLevel ? warm : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(level <= maxPriceLevel ? warm : sand, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(sand, lineWidth: 1)
        }
    }

    private var spinButton: some View {

        NavigationLink(destination: WheelView(selectedCategories: selectedCategories, selectedMeal: selectedMeal, maxPriceLevel: maxPriceLevel, maxDistance: distance)) {

            Text("開始抽選")
                .font(.system(size: 18, weight: .semibold))
                .tracking(4)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(warm)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
