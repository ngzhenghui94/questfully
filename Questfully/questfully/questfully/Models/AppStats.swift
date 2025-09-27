import Foundation

struct AppStats: Codable {
    let totalQuestions: Int
    let totalCategories: Int
    let questionsPerCategory: [UUID: Int]

    private enum CodingKeys: String, CodingKey {
        case totalQuestions
        case totalCategories
        case questionsPerCategory
    }

    init(totalQuestions: Int, totalCategories: Int, questionsPerCategory: [UUID: Int]) {
        self.totalQuestions = totalQuestions
        self.totalCategories = totalCategories
        self.questionsPerCategory = questionsPerCategory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        totalCategories = try container.decode(Int.self, forKey: .totalCategories)

        if let keyedDictionary = try? container.decode([String: Int].self, forKey: .questionsPerCategory) {
            var mapped: [UUID: Int] = [:]
            for (key, value) in keyedDictionary {
                if let uuid = UUID(uuidString: key) {
                    mapped[uuid] = value
                }
            }
            questionsPerCategory = mapped
        } else {
            questionsPerCategory = try container.decode([UUID: Int].self, forKey: .questionsPerCategory)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalQuestions, forKey: .totalQuestions)
        try container.encode(totalCategories, forKey: .totalCategories)
        let stringKeyed = Dictionary(uniqueKeysWithValues: questionsPerCategory.map { ($0.key.uuidString, $0.value) })
        try container.encode(stringKeyed, forKey: .questionsPerCategory)
    }
}

