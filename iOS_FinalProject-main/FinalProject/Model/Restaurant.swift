import Foundation

struct Restaurant: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var category: String
    var emoji: String

    static let defaults: [Restaurant] = [
        Restaurant(name: "一蘭拉麵", category: "拉麵", emoji: "🍜"),
        Restaurant(name: "藏壽司", category: "日式", emoji: "🍱"),
        Restaurant(name: "鼎泰豐", category: "台式", emoji: "🥢"),
        Restaurant(name: "五桐號", category: "手搖飲", emoji: "🧋"),
        Restaurant(name: "麥當勞", category: "美式", emoji: "🍔"),
        Restaurant(name: "八方雲集", category: "台式", emoji: "🥟"),
    ]
}
