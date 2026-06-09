import SwiftUI

struct FavoritesView: View {
    @Environment(\.openURL) private var openURL
    @Environment(FavoritesStore.self) private var store
    @State private var showAddSheet = false
    @State private var editingRestaurant: Restaurant? = nil

    private let accent = Color(red: 1.0, green: 0.38, blue: 0.18)

    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.97, blue: 0.94).ignoresSafeArea()

            if store.favorites.isEmpty {
                emptyState
            } else {
                List {
                    favoriteSpinSection
                    favoritesSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("我的最愛")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(accent)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddRestaurantView()
                .environment(store)
        }
        .sheet(item: $editingRestaurant) { restaurant in
            RestaurantNoteSheet(restaurant: restaurant)
                .environment(store)
        }
    }

    // MARK: - Sections

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("💫")
                .font(.system(size: 64))
            Text("還沒有最愛的餐廳")
                .font(.title3)
                .fontWeight(.bold)
            Text("點右上角 + 新增餐廳\n或從轉盤結果加入最愛")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showAddSheet = true
            } label: {
                Label("新增餐廳", systemImage: "plus.circle.fill")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(accent)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private var favoriteSpinSection: some View {
        Section {
            NavigationLink(destination: WheelView(fixedRestaurants: store.favorites)) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accent, Color(red: 0.85, green: 0.22, blue: 0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("從最愛抽扭蛋")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("從 \(store.favorites.count) 間最愛餐廳中隨機抽選")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        Section {
            ForEach(store.favorites) { restaurant in
                restaurantRow(restaurant)
            }
            .onDelete { store.removeFromFavorites(at: $0) }
        } header: {
            Label("所有最愛", systemImage: "heart.fill")
                .font(.subheadline)
                .foregroundStyle(accent)
                .textCase(nil)
        } footer: {
            Text("左滑刪除餐廳・所有最愛都會加入扭蛋機")
                .font(.caption)
        }
    }

    private func restaurantRow(_ restaurant: Restaurant) -> some View {
        HStack(spacing: 12) {
            Text(restaurant.emoji)
                .font(.title2)
                .frame(width: 42, height: 42)
                .background(accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                editingRestaurant = restaurant
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(restaurant.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if restaurant.note.isEmpty {
                        Text(restaurant.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                            Text(restaurant.note)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(accent.opacity(0.8))
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                openGoogleMaps(for: restaurant)
            } label: {
                Image(systemName: "map")
                    .font(.title3)
                    .foregroundStyle(accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func openGoogleMaps(for restaurant: Restaurant) {
        if let url = restaurant.googleMapsSearchURL {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environment(FavoritesStore())
    }
}
