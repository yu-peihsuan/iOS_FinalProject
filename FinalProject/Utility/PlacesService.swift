import Foundation
import CoreLocation

enum PlacesService {
    private static let apiKey = "AIzaSyBscuEg_dzu-iKGw6uBvqYzq-vJAxtwOm4"

    private static let categoryKeywords: [String: (keyword: String, emoji: String)] = [
        "日式": ("日式餐廳", "🍱"),
        "台式": ("台式餐廳", "🥢"),
        "韓式": ("韓式餐廳", "🌶️"),
        "美式": ("美式餐廳", "🍔"),
        "義式": ("義式餐廳", "🍝"),
        "火鍋": ("火鍋", "🫕"),
        "拉麵": ("拉麵", "🍜"),
        "手搖飲": ("手搖飲", "🧋"),
        "港式": ("港式餐廳", "🥠"),
        "泰式": ("泰式餐廳", "🍛"),
        "素食": ("素食餐廳", "🥗"),
        "甜點": ("甜點", "🧁"),
    ]

    private static let categoryDefaultPriceLevel: [String: Int] = [
        "日式": 2, "台式": 1, "韓式": 2, "美式": 1,
        "義式": 2, "火鍋": 2, "拉麵": 2, "手搖飲": 1,
        "港式": 2, "泰式": 2, "素食": 2, "甜點": 1,
    ]

    private struct PlaceWithCoord {
        var restaurant: Restaurant
        var coord: CLLocationCoordinate2D
    }

    private static func searchNearbyWithCoords(
        location: CLLocationCoordinate2D,
        category: String,
        meal: String,
        radiusMeters: Int
    ) async throws -> [PlaceWithCoord] {
        guard let info = categoryKeywords[category] else { return [] }

        let keyword: String
        switch meal {
        case "早餐":
            keyword = "\(info.keyword) 早餐"
        case "午餐":
            keyword = "\(info.keyword) 午餐"
        case "晚餐":
            keyword = "\(info.keyword) 晚餐"
        case "點心":
            keyword = "\(info.keyword) 下午茶"
        default:
            keyword = info.keyword
        }

        let url = URL(string: "https://places.googleapis.com/v1/places:searchText")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.displayName,places.location,places.priceLevel,places.rating",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

        let body: [String: Any] = [
            "textQuery": keyword,
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": location.latitude,
                        "longitude": location.longitude
                    ],
                    "radius": Double(radiusMeters)
                ]
            ],
            "languageCode": "zh-TW",
            "openNow": true,
            "maxResultCount": 20
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(NewPlacesResponse.self, from: data)

        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let priceLevelMap: [String: Int] = [
            "PRICE_LEVEL_FREE": 0,
            "PRICE_LEVEL_INEXPENSIVE": 1,
            "PRICE_LEVEL_MODERATE": 2,
            "PRICE_LEVEL_EXPENSIVE": 3,
            "PRICE_LEVEL_VERY_EXPENSIVE": 4
        ]

        return (response.places ?? []).map { place in
            let placeCoord = CLLocationCoordinate2D(
                latitude: place.location.latitude,
                longitude: place.location.longitude
            )
            let straightLine = userLocation.distance(from: CLLocation(
                latitude: placeCoord.latitude,
                longitude: placeCoord.longitude
            )) / 1000.0

            let level = place.priceLevel.flatMap { priceLevelMap[$0] }
                ?? categoryDefaultPriceLevel[category]
                ?? 2

            let restaurant = Restaurant(
                name: place.displayName.text,
                category: category,
                emoji: info.emoji,
                priceLevel: level,
                mealTypes: ["早餐", "午餐", "晚餐", "點心"],
                distance: round(straightLine * 10) / 10
            )
            return PlaceWithCoord(restaurant: restaurant, coord: placeCoord)
        }
    }

    private static func fetchWalkingDistances(
        origin: CLLocationCoordinate2D,
        places: [PlaceWithCoord]
    ) async -> [Double?] {
        guard !places.isEmpty else { return [] }

        var allDistances = [Double?](repeating: nil, count: places.count)
        let batchSize = 25

        for batchStart in stride(from: 0, to: places.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, places.count)
            let batch = places[batchStart..<batchEnd]

            let destinations = batch
                .map { "\($0.coord.latitude),\($0.coord.longitude)" }
                .joined(separator: "|")

            var components = URLComponents(string: "https://maps.googleapis.com/maps/api/distancematrix/json")!
            components.queryItems = [
                URLQueryItem(name: "origins", value: "\(origin.latitude),\(origin.longitude)"),
                URLQueryItem(name: "destinations", value: destinations),
                URLQueryItem(name: "mode", value: "walking"),
                URLQueryItem(name: "language", value: "zh-TW"),
                URLQueryItem(name: "key", value: apiKey),
            ]

            guard let url = components.url else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(DistanceMatrixResponse.self, from: data)

                if let elements = response.rows.first?.elements {
                    for (i, element) in elements.enumerated() {
                        if let meters = element.distance?.value {
                            allDistances[batchStart + i] = round(Double(meters) / 100.0) / 10.0
                        }
                    }
                }
            } catch {
                print("[DEBUG] Distance Matrix API 失敗: \(error.localizedDescription)")
            }
        }

        return allDistances
    }

    static func searchAll(
        location: CLLocationCoordinate2D,
        categories: Set<String>,
        meal: String,
        radiusMeters: Int
    ) async -> [Restaurant] {
        var allPlaces: [PlaceWithCoord] = []

        await withTaskGroup(of: [PlaceWithCoord].self) { group in
            for category in categories {
                group.addTask {
                    (try? await searchNearbyWithCoords(
                        location: location,
                        category: category,
                        meal: meal,
                        radiusMeters: radiusMeters
                    )) ?? []
                }
            }
            for await results in group {
                allPlaces.append(contentsOf: results)
            }
        }

        let walkingDistances = await fetchWalkingDistances(origin: location, places: allPlaces)

        var restaurants = allPlaces.map(\.restaurant)
        for i in restaurants.indices {
            if let realDist = walkingDistances[i] {
                restaurants[i].distance = realDist
            }
        }

        return restaurants.shuffled()
    }
}

// MARK: - Places API (New) Response

private struct NewPlacesResponse: Codable {
    let places: [NewPlace]?
}

private struct NewPlace: Codable {
    let displayName: DisplayName
    let location: NewPlaceLocation
    let priceLevel: String?
    let rating: Double?
}

private struct DisplayName: Codable {
    let text: String
}

private struct NewPlaceLocation: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Distance Matrix Response

private struct DistanceMatrixResponse: Codable {
    let rows: [DistanceMatrixRow]
}

private struct DistanceMatrixRow: Codable {
    let elements: [DistanceMatrixElement]
}

private struct DistanceMatrixElement: Codable {
    let distance: DistanceValue?
    let duration: DistanceValue?
    let status: String
}

private struct DistanceValue: Codable {
    let text: String
    let value: Int
}
