import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let color: String
}
