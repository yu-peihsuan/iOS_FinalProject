import Foundation
import Observation
import SwiftUI

@Observable
class FavoritesStore {
    var favorites: [Restaurant] = []
    var wantToEat: [Restaurant] = []
    var history: [SpinRecord] = []

    private let favKey     = "favorites_v1"
    private let wantKey    = "wantToEat_v1"
    private let historyKey = "spinHistory_v1"

    init() { load() }

    // MARK: - Favorites

    func isFavorite(_ restaurant: Restaurant) -> Bool {
        favorites.contains { $0.name == restaurant.name }
    }

    func addRestaurant(_ restaurant: Restaurant) {
        guard !isFavorite(restaurant) else { return }
        favorites.append(restaurant)
        save()
    }

    func toggleFavorite(_ restaurant: Restaurant) {
        if let idx = favorites.firstIndex(where: { $0.name == restaurant.name }) {
            favorites.remove(at: idx)
            wantToEat.removeAll { $0.name == restaurant.name }
        } else {
            favorites.append(restaurant)
        }
        save()
    }

    func removeFromFavorites(at offsets: IndexSet) {
        let removedNames = offsets.map { favorites[$0].name }
        favorites.remove(atOffsets: offsets)
        wantToEat.removeAll { removedNames.contains($0.name) }
        save()
    }

    func updateNote(for id: UUID, note: String) {
        if let idx = favorites.firstIndex(where: { $0.id == id }) {
            favorites[idx].note = note
        }
        if let idx = wantToEat.firstIndex(where: { $0.id == id }) {
            wantToEat[idx].note = note
        }
        save()
    }

    // MARK: - Want to Eat

    func isWantToEat(_ restaurant: Restaurant) -> Bool {
        wantToEat.contains { $0.id == restaurant.id }
    }

    func toggleWantToEat(_ restaurant: Restaurant) {
        if let idx = wantToEat.firstIndex(where: { $0.id == restaurant.id }) {
            wantToEat.remove(at: idx)
        } else {
            if !isFavorite(restaurant) {
                favorites.append(restaurant)
            }
            wantToEat.append(restaurant)
        }
        save()
    }

    func removeFromWantToEat(at offsets: IndexSet) {
        wantToEat.remove(atOffsets: offsets)
        save()
    }

    // MARK: - History

    func addToHistory(_ restaurant: Restaurant) {
        history.insert(SpinRecord(restaurant: restaurant, date: Date()), at: 0)
        if history.count > 200 { history = Array(history.prefix(200)) }
        save()
    }

    func removeFromHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        save()
    }

    func clearHistory() {
        history.removeAll()
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favKey)
        }
        if let data = try? JSONEncoder().encode(wantToEat) {
            UserDefaults.standard.set(data, forKey: wantKey)
        }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: favKey),
           let decoded = try? JSONDecoder().decode([Restaurant].self, from: data) {
            favorites = decoded
        }
        if let data = UserDefaults.standard.data(forKey: wantKey),
           let decoded = try? JSONDecoder().decode([Restaurant].self, from: data) {
            wantToEat = decoded
        }
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([SpinRecord].self, from: data) {
            history = decoded
        }
    }
}
