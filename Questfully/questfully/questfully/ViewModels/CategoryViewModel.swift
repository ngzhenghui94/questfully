import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var questions: [UUID: [Question]] = [:]
    @Published var stats: AppStats? = nil
    @Published var questionCounts: [UUID: Int] = [:]
    @Published var viewedCount: Int = 0
    @Published var totalQuestionsForFocusedCategory: Int = 0
    @Published var focusedCategoryID: UUID? = nil
    private var apiService = APIService()

    init() {
        fetchCategories()
        fetchStats()
    }

    func fetchCategories() {
        apiService.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    categories.forEach { category in
                        self?.fetchQuestions(for: category)
                        self?.fetchQuestionCount(for: category.id)
                    }
                case .failure(let error):
                    print("Error fetching categories: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchQuestions(for category: Category) {
        let categoryID = category.id
        apiService.fetchQuestions(for: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    let normalizedQuestions = questions.map { question -> Question in
                        if question.categoryId == categoryID {
                            return question
                        }
                        return Question(id: question.id, text: question.text, categoryId: categoryID)
                    }
                    self?.questions[categoryID] = normalizedQuestions
                    self?.recalculateViewedCount()
                case .failure(let error):
                    print("Error fetching questions for category \(category.name): \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchStats() {
        apiService.fetchStats { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stats):
                    self?.stats = stats
                    self?.questionCounts = stats.questionsPerCategory
                    self?.recalculateViewedCount()
                case .failure(let error):
                    print("Error fetching stats: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateFocusedCategory(to categoryID: UUID?) {
        focusedCategoryID = categoryID
        recalculateViewedCount()
    }

    private func recalculateViewedCount() {
        guard let stats = stats else {
            viewedCount = 0
            totalQuestionsForFocusedCategory = focusedCategoryID.flatMap { questionCounts[$0] } ?? 0
            return
        }

        guard let categoryID = focusedCategoryID else {
            let totalLoaded = questions.values.reduce(0) { $0 + $1.count }
            viewedCount = min(totalLoaded, stats.totalQuestions)
            totalQuestionsForFocusedCategory = stats.totalQuestions
            return
        }

        let totalForCategory = questionCounts[categoryID] ?? stats.questionsPerCategory[categoryID] ?? 0
        let loadedForCategory = questions[categoryID]?.count ?? totalForCategory
        viewedCount = min(loadedForCategory, totalForCategory)
        totalQuestionsForFocusedCategory = totalForCategory
    }

    private func fetchQuestionCount(for categoryID: UUID) {
        apiService.fetchQuestionCount(for: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    self?.questionCounts[categoryID] = count
                    self?.recalculateViewedCount()
                case .failure(let error):
                    print("Error fetching question count for category: \(error.localizedDescription)")
                }
            }
        }
    }
}
