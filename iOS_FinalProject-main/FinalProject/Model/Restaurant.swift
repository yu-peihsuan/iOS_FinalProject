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

    var googleMapsSearchURL: URL? {
        var components = URLComponents(string: "https://www.google.com/maps/search/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: name)
        ]
        return components?.url
    }

    static let defaults: [Restaurant] = [
        Restaurant(name: "藏壽司", category: "日式", emoji: "🍣"),
        Restaurant(name: "壽司郎", category: "日式", emoji: "🍱"),
        Restaurant(name: "爭鮮", category: "日式", emoji: "🍙"),
        Restaurant(name: "鼎泰豐", category: "台式", emoji: "🥢"),
        Restaurant(name: "八方雲集", category: "台式", emoji: "🥟"),
        Restaurant(name: "鬍鬚張", category: "台式", emoji: "🍚"),
        Restaurant(name: "兩餐", category: "韓式", emoji: "🌶️"),
        Restaurant(name: "涓豆腐", category: "韓式", emoji: "🍲"),
        Restaurant(name: "起家雞", category: "韓式", emoji: "🍗"),
        Restaurant(name: "麥當勞", category: "美式", emoji: "🍔"),
        Restaurant(name: "肯德基", category: "美式", emoji: "🍗"),
        Restaurant(name: "樂子", category: "美式", emoji: "🥞"),
        Restaurant(name: "薄多義", category: "義式", emoji: "🍝"),
        Restaurant(name: "貳樓", category: "義式", emoji: "🍕"),
        Restaurant(name: "義饗食堂", category: "義式", emoji: "🍽️"),
        Restaurant(name: "石二鍋", category: "火鍋", emoji: "🫕"),
        Restaurant(name: "築間", category: "火鍋", emoji: "🍲"),
        Restaurant(name: "這一鍋", category: "火鍋", emoji: "🥘"),
        Restaurant(name: "一蘭拉麵", category: "拉麵", emoji: "🍜"),
        Restaurant(name: "麵屋武藏", category: "拉麵", emoji: "🍜"),
        Restaurant(name: "鬼金棒", category: "拉麵", emoji: "🍜"),
        Restaurant(name: "五桐號", category: "手搖飲", emoji: "🧋"),
        Restaurant(name: "迷客夏", category: "手搖飲", emoji: "🥛"),
        Restaurant(name: "可不可", category: "手搖飲", emoji: "🧋"),
        Restaurant(name: "添好運", category: "港式", emoji: "🥠"),
        Restaurant(name: "點點心", category: "港式", emoji: "🥟"),
        Restaurant(name: "了凡", category: "港式", emoji: "🍖"),
        Restaurant(name: "瓦城", category: "泰式", emoji: "🍛"),
        Restaurant(name: "非常泰", category: "泰式", emoji: "🥭"),
        Restaurant(name: "泰市場", category: "泰式", emoji: "🦐"),
        Restaurant(name: "果然匯", category: "素食", emoji: "🥗"),
        Restaurant(name: "小小樹食", category: "素食", emoji: "🥬"),
        Restaurant(name: "蔬河", category: "素食", emoji: "🌯"),
        Restaurant(name: "Lady M", category: "甜點", emoji: "🍰"),
        Restaurant(name: "亞尼克", category: "甜點", emoji: "🧁"),
        Restaurant(name: "Mister Donut", category: "甜點", emoji: "🍩"),
    ]
}
