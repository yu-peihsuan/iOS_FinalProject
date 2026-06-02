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
                    wantToEatSection
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

    @ViewBuilder
    private var wantToEatSection: some View {
        Section {
            if store.wantToEat.isEmpty {
                Label("從下方最愛清單點 ○ 加入轉盤", systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(store.wantToEat) { restaurant in
                    restaurantRow(restaurant, showToggle: false)
                }
                .onDelete { store.removeFromWantToEat(at: $0) }
            }
        } header: {
            Label("轉盤餐廳清單", systemImage: "arrow.triangle.2.circlepath")
                .font(.subheadline)
                .foregroundStyle(accent)
                .textCase(nil)
        } footer: {
            if store.wantToEat.isEmpty {
                Text("若清單為空，轉盤會使用預設餐廳")
                    .font(.caption)
            } else {
                Text("共 \(store.wantToEat.count) 間・轉盤將只顯示這些餐廳")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        Section {
            ForEach(store.favorites) { restaurant in
                restaurantRow(restaurant, showToggle: true)
            }
            .onDelete { store.removeFromFavorites(at: $0) }
        } header: {
            Label("所有最愛", systemImage: "heart.fill")
                .font(.subheadline)
                .foregroundStyle(accent)
                .textCase(nil)
        } footer: {
            Text("左滑刪除餐廳・點 ○ 加入轉盤清單")
                .font(.caption)
        }
    }

    private func restaurantRow(_ restaurant: Restaurant, showToggle: Bool) -> some View {
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

            if showToggle {
                let isWanted = store.isWantToEat(restaurant)
                Button {
                    store.toggleWantToEat(restaurant)
                } label: {
                    Image(systemName: isWanted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isWanted ? accent : Color.gray.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
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
