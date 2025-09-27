import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var questions: [UUID: [Question]] = [:]
    @Published var stats: AppStats? = nil
    @Published var questionCounts: [UUID: Int] = [:]
    @Published var viewedCount: Int = 0
    @Published var totalQuestionsForFocusedCategory: Int = 0
    @Published var focusedCategoryID: UUID? = nil

    private let dataStore: ContentDataStore
    private var cancellables: Set<AnyCancellable> = []

    init(dataStore: ContentDataStore? = nil) {
        let resolvedStore = dataStore ?? ContentDataStore()
        self.dataStore = resolvedStore

        resolvedStore.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.categories = categories
                if self?.focusedCategoryID == nil {
                    self?.focusedCategoryID = categories.first?.id
                }
            }
            .store(in: &cancellables)

        resolvedStore.$questions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newQuestions in
                self?.questions = newQuestions
                self?.recalculateViewedCount()
            }
            .store(in: &cancellables)

        resolvedStore.$stats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.stats = stats
                self?.questionCounts = stats?.questionsPerCategory ?? [:]
                self?.recalculateViewedCount()
            }
            .store(in: &cancellables)

        Task { await resolvedStore.refreshContent() }
    }

    func questions(for category: Category) -> [Question] {
        dataStore.questions(for: category.id)
    }

    func updateFocusedCategory(to categoryID: UUID?) {
        focusedCategoryID = categoryID
        recalculateViewedCount()
    }

    var focusedCategoryQuestionCount: Int? {
        guard let categoryID = focusedCategoryID else { return nil }
        return questionCounts[categoryID] ?? stats?.questionsPerCategory[categoryID]
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
}
