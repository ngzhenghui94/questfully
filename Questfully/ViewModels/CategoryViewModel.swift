import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var questions: [String: [Question]] = [:]

    init() {
        loadMockData()
    }

    func loadMockData() {
        // Mock data for categories
        self.categories = [
            Category(id: "1", name: "Deep Questions", color: "8E44AD"),
            Category(id: "2", name: "Faith & Beliefs", color: "3498DB"),
            Category(id: "3", name: "Silly Questions", color: "2ECC71"),
            Category(id: "4", name: "Relationship", color: "E74C3C"),
            Category(id: "5", name: "Self-Reflection", color: "F1C40F")
        ]
        
        // Mock data for questions, grouped by category
        self.questions = [
            "1": [
                Question(id: "q1", text: "What is a belief you hold with which many people disagree?", categoryId: "1"),
                Question(id: "q2", text: "What is the most important lesson you've learned in life?", categoryId: "1")
            ],
            "2": [
                Question(id: "q3", text: "If love is real do you think it points to something bigger than biology?", categoryId: "2")
            ],
            "3": [],
            "4": [],
            "5": []
        ]
    }
}
