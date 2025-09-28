import Foundation

@MainActor
final class ContentDataStore: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var questions: [UUID: [Question]] = [:]
    @Published private(set) var stats: AppStats?

    private let apiService: APIService
    private let localStore: LocalDataStore

    init(apiService: APIService = APIService(), localStore: LocalDataStore = .shared) {
        self.apiService = apiService
        self.localStore = localStore
        loadCachedData()
    }

    var apiClient: APIService {
        apiService
    }

    func refreshContent() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchCategoriesAndQuestions() }
            group.addTask { await self.fetchStats() }
        }
    }

    func questions(for categoryID: UUID) -> [Question] {
        questions[categoryID] ?? []
    }

    private func loadCachedData() {
        categories = localStore.loadCategories()
        questions = localStore.loadQuestions()
        stats = localStore.loadStats()
    }

    private func fetchCategoriesAndQuestions() async {
        switch await apiService.fetchCategories() {
        case .success(let categories):
            categories.forEach { category in
                questions[category.id] = questions[category.id] ?? []
            }
            self.categories = categories
            localStore.save(categories: categories)
            await fetchQuestions(for: categories)
        case .failure(let error):
            print("ContentDataStore: Failed to fetch categories - \(error.localizedDescription)")
        }
    }

    private func fetchQuestions(for categories: [Category]) async {
        var updatedQuestions = questions
        for category in categories {
            let result = await apiService.fetchQuestions(for: category.id)
            switch result {
            case .success(let fetchedQuestions):
                let normalized = fetchedQuestions.map { question -> Question in
                    if question.categoryId == category.id {
                        return question
                    }
                    return Question(id: question.id, text: question.text, categoryId: category.id)
                }
                updatedQuestions[category.id] = normalized
            case .failure(let error):
                print("ContentDataStore: Failed to fetch questions for \(category.name) - \(error.localizedDescription)")
            }
        }

        questions = updatedQuestions
        localStore.save(questions: updatedQuestions)
    }

    private func fetchStats() async {
        let result = await apiService.fetchStats()
        switch result {
        case .success(let stats):
            self.stats = stats
            localStore.save(stats: stats)
        case .failure(let error):
            print("ContentDataStore: Failed to fetch stats - \(error.localizedDescription)")
        }
    }
}

