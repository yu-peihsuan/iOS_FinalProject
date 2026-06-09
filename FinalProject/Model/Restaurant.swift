import Foundation

struct Restaurant: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var category: String
    var emoji: String
    var note: String = ""
    var priceLevel: Int = 2
    var mealTypes: [String] = ["午餐", "晚餐"]
    var distance: Double = 3.0

    enum CodingKeys: String, CodingKey {
        case id, name, category, emoji, note, priceLevel, mealTypes, distance
    }

    init(id: UUID = UUID(), name: String, category: String, emoji: String, note: String = "", priceLevel: Int = 2, mealTypes: [String] = ["午餐", "晚餐"], distance: Double = 3.0) {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.note = note
        self.priceLevel = priceLevel
        self.mealTypes = mealTypes
        self.distance = distance
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = try c.decode(UUID.self,   forKey: .id)
        name       = try c.decode(String.self, forKey: .name)
        category   = try c.decode(String.self, forKey: .category)
        emoji      = try c.decode(String.self, forKey: .emoji)
        note       = (try? c.decodeIfPresent(String.self, forKey: .note)) ?? ""
        priceLevel = (try? c.decodeIfPresent(Int.self, forKey: .priceLevel)) ?? 2
        mealTypes  = (try? c.decodeIfPresent([String].self, forKey: .mealTypes)) ?? ["午餐", "晚餐"]
        distance   = (try? c.decodeIfPresent(Double.self, forKey: .distance)) ?? 3.0
    }

    var googleMapsSearchURL: URL? {
        var components = URLComponents(string: "https://www.google.com/maps/search/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: name)
        ]
        return components?.url
    }

}
