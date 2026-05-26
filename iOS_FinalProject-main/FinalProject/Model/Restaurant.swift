import Foundation

struct Restaurant: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var category: String
    var emoji: String
    var note: String = ""

    enum CodingKeys: String, CodingKey {
        case id, name, category, emoji, note
    }

    init(id: UUID = UUID(), name: String, category: String, emoji: String, note: String = "") {
        self.id = id
        self.name = name
        self.category = category
        self.emoji = emoji
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = try c.decode(UUID.self,   forKey: .id)
        name     = try c.decode(String.self, forKey: .name)
        category = try c.decode(String.self, forKey: .category)
        emoji    = try c.decode(String.self, forKey: .emoji)
        note     = (try? c.decodeIfPresent(String.self, forKey: .note)) ?? ""
    }

    static let defaults: [Restaurant] = [
        Restaurant(name: "一蘭拉麵", category: "拉麵",  emoji: "🍜"),
        Restaurant(name: "藏壽司",   category: "日式",  emoji: "🍱"),
        Restaurant(name: "鼎泰豐",   category: "台式",  emoji: "🥢"),
        Restaurant(name: "五桐號",   category: "手搖飲", emoji: "🧋"),
        Restaurant(name: "麥當勞",   category: "美式",  emoji: "🍔"),
        Restaurant(name: "八方雲集", category: "台式",  emoji: "🥟"),
    ]
}
