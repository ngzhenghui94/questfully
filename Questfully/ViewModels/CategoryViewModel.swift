import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var questions: [UUID: [Question]] = [:]
    private var apiService = APIService()

    init() {
        fetchCategories()
    }

    func fetchCategories() {
        apiService.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    categories.forEach { category in
                        self?.fetchQuestions(for: category)
                    }
                case .failure(let error):
                    print("Error fetching categories: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchQuestions(for category: Category) {
        guard let categoryID = category.id else {
            print("Category ID is nil")
            return
        }
        apiService.fetchQuestions(for: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.questions[categoryID] = questions
                case .failure(let error):
                    print("Error fetching questions for category \(category.name): \(error.localizedDescription)")
                }
            }
        }
    }
}
