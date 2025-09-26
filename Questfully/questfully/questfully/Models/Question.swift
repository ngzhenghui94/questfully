import Foundation

struct Question: Identifiable, Codable {
    let id: String
    let text: String
    let categoryId: String
}
