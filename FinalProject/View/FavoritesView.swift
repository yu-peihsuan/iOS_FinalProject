import SwiftUI

struct FavoritesView: View {
    @Environment(\.openURL) private var openURL
    @Environment(FavoritesStore.self) private var store
    @State private var showAddSheet = false
    @State private var editingRestaurant: Restaurant? = nil

    private let warm = Color(red: 0.55, green: 0.42, blue: 0.32)
    private let dusty = Color(red: 0.62, green: 0.42, blue: 0.44)
    private let sand = Color(red: 0.82, green: 0.76, blue: 0.68)

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.92).ignoresSafeArea()

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
                        .foregroundStyle(warm)
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
            Image(systemName: "heart")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(dusty)
            Text("還沒有最愛的餐廳")
                .font(.system(size: 18, weight: .light))
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
                    .background(warm)
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
                                warm
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("從最愛抽扭蛋")
                            .font(.system(size: 15, weight: .medium))
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
                .foregroundStyle(warm)
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
                .frame(width: 44, height: 44)
                .background(warm.opacity(0.1))
                .clipShape(Circle())

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
                        .foregroundStyle(warm.opacity(0.8))
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
                    .foregroundStyle(warm)
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
