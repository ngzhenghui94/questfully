import Foundation

class FavoritesManager: ObservableObject {
    @Published var favoritedQuestions: [Question] = [] {
        didSet {
            saveFavorites()
        }
    }

    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoritedQuestions"

    init() {
        loadFavorites()
    }

    func addFavorite(_ question: Question) {
        if !favoritedQuestions.contains(where: { $0.id == question.id }) {
            favoritedQuestions.append(question)
        }
    }

    func removeFavorite(_ question: Question) {
        favoritedQuestions.removeAll { $0.id == question.id }
    }

    func isFavorited(_ question: Question) -> Bool {
        favoritedQuestions.contains { $0.id == question.id }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoritedQuestions) {
            defaults.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let savedFavorites = defaults.object(forKey: favoritesKey) as? Data {
            if let decodedFavorites = try? JSONDecoder().decode([Question].self, from: savedFavorites) {
                favoritedQuestions = decodedFavorites
            }
        }
    }
}
