import Foundation

struct SpinRecord: Identifiable, Codable {
    var id = UUID()
    var restaurant: Restaurant
    var date: Date
}
