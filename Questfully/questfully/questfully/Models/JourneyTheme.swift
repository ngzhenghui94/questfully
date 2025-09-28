import Foundation

struct JourneyTheme: Identifiable, Hashable {
    struct Step: Identifiable, Hashable {
        let id: UUID
        let title: String
        let prompt: Question
        let reflection: String?

        init(id: UUID = UUID(), title: String, prompt: Question, reflection: String? = nil) {
            self.id = id
            self.title = title
            self.prompt = prompt
            self.reflection = reflection
        }
    }

    let id: UUID
    let slug: String
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let steps: [Step]

    var featuredQuestions: [Question] {
        steps.map { $0.prompt }
    }

    init(id: UUID = UUID(), slug: String, title: String, subtitle: String, description: String, icon: String, steps: [Step]) {
        self.id = id
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.icon = icon
        self.steps = steps
    }
}

struct JourneyThemeProgress: Identifiable, Codable, Equatable {
    let id: UUID?
    let themeId: UUID
    var currentStep: Int
    var completed: Bool
    let updatedAt: Date?

    init(id: UUID? = nil, themeId: UUID, currentStep: Int = 1, completed: Bool = false, updatedAt: Date? = nil) {
        self.id = id
        self.themeId = themeId
        self.currentStep = currentStep
        self.completed = completed
        self.updatedAt = updatedAt
    }

    static func initial(for themeId: UUID) -> JourneyThemeProgress {
        JourneyThemeProgress(themeId: themeId, currentStep: 1, completed: false)
    }
}


