import SwiftUI

struct ContentView: View {

    @State private var selectedMeal = "晚餐"
    @State private var selectedCategory = "日式"

    @State private var budget: Double = 300
    @State private var distance: Double = 3

    let meals = ["早餐", "午餐", "晚餐", "點心"]

    let categories = [
        "日式", "台式",
        "韓式", "美式",
        "義式", "火鍋",
        "拉麵", "手搖飲"
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.2),
                        Color.yellow.opacity(0.15),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(spacing: 24) {

                        headerSection

                        mealSection

                        categorySection

                        filterSection

                        NavigationLink {

                            WheelView()

                        } label: {

                            HStack {

                                Image(systemName: "sparkles")

                                Text("開始幫我選！")
                                    .fontWeight(.bold)
                            }
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 22)
                            )
                            .shadow(
                                color: .orange.opacity(0.35),
                                radius: 8,
                                x: 0,
                                y: 5
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Components

extension ContentView {

    private var headerSection: some View {

        VStack(spacing: 12) {

            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundStyle(.orange)

            Text("今天吃什麼？")
                .font(.system(size: 34, weight: .bold))

            Text("選擇你的美食偏好\n讓系統幫你做決定！")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var mealSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack {

                Image(systemName: "clock.fill")
                    .foregroundStyle(.orange)

                Text("選擇用餐時段")
                    .font(.headline)
            }

            HStack(spacing: 12) {

                ForEach(meals, id: \.self) { meal in

                    Button {

                        selectedMeal = meal

                    } label: {

                        Text(meal)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedMeal == meal
                                ? Color.orange
                                : Color.white
                            )
                            .foregroundStyle(
                                selectedMeal == meal
                                ? Color.white
                                : Color.black
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var categorySection: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack {

                Image(systemName: "fork.knife")
                    .foregroundStyle(.orange)

                Text("選擇食物類別")
                    .font(.headline)
            }

            LazyVGrid(columns: columns, spacing: 14) {

                ForEach(categories, id: \.self) { category in

                    Button {

                        selectedCategory = category

                    } label: {

                        HStack {

                            Image(systemName:
                                    selectedCategory == category
                                  ? "checkmark.circle.fill"
                                  : "circle")

                            Text(category)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedCategory == category
                            ? Color.orange.opacity(0.18)
                            : Color.white
                        )
                        .foregroundStyle(
                            selectedCategory == category
                            ? Color.orange
                            : Color.black
                        )
                        .overlay {

                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    selectedCategory == category
                                    ? Color.orange
                                    : Color.gray.opacity(0.2),
                                    lineWidth: 1.5
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var filterSection: some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack {

                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.orange)

                Text("進階篩選")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 12) {

                HStack {

                    Text("搜尋距離")

                    Spacer()

                    Text(String(format: "%.0f 公里", distance))
                        .foregroundStyle(.orange)
                        .fontWeight(.bold)
                }

                Slider(
                    value: $distance,
                    in: 1...10,
                    step: 1
                )
                .tint(.orange)
            }

            VStack(alignment: .leading, spacing: 12) {

                HStack {

                    Text("預算")

                    Spacer()

                    Text("$\(Int(budget))")
                        .foregroundStyle(.orange)
                        .fontWeight(.bold)
                }

                Slider(
                    value: $budget,
                    in: 100...1000,
                    step: 50
                )
                .tint(.orange)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
