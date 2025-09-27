import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let categoryId: UUID
}
