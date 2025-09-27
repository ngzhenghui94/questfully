import Foundation

class FavoritesManager: ObservableObject {
    @Published private(set) var favoritedQuestions: [Question] = []

    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoritedQuestions"
    private let deviceIdKey = "deviceIdentifier"
    private let apiService = APIService()

    private var deviceId: String {
        if let existing = defaults.string(forKey: deviceIdKey) {
            return existing
        }
        let newId = UUID().uuidString
        defaults.set(newId, forKey: deviceIdKey)
        return newId
    }

    init() {
        loadFavorites()
        syncFavorites()
    }

    func addFavorite(_ question: Question) {
        if !favoritedQuestions.contains(where: { $0.id == question.id }) {
            favoritedQuestions.append(question)
            saveFavorites()
            apiService.addFavorite(deviceId: deviceId, questionId: question.id) { result in
                if case .failure(let error) = result {
                    print("Error syncing favorite add: \(error.localizedDescription)")
                }
            }
        }
    }

    func removeFavorite(_ question: Question) {
        favoritedQuestions.removeAll { $0.id == question.id }
        saveFavorites()
        apiService.removeFavorite(deviceId: deviceId, questionId: question.id) { result in
            if case .failure(let error) = result {
                print("Error syncing favorite remove: \(error.localizedDescription)")
            }
        }
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

    private func syncFavorites() {
        apiService.fetchFavorites(deviceId: deviceId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questionIds):
                    self?.mergeFavorites(with: questionIds)
                case .failure(let error):
                    print("Error fetching favorites from server: \(error.localizedDescription)")
                }
            }
        }
    }

    private func mergeFavorites(with remoteQuestions: [Question]) {
        let remoteMap = Dictionary(uniqueKeysWithValues: remoteQuestions.map { ($0.id, $0) })
        let remoteIds = Set(remoteMap.keys)

        // Remove local favorites that no longer exist remotely
        favoritedQuestions.removeAll { !remoteIds.contains($0.id) }

        // Merge remote details into local cache
        var updatedFavorites: [Question] = []
        for question in favoritedQuestions {
            if let remote = remoteMap[question.id] {
                updatedFavorites.append(remote)
            } else {
                updatedFavorites.append(question)
            }
        }

        // Add any new remote favorites not present locally
        for remote in remoteQuestions where !updatedFavorites.contains(where: { $0.id == remote.id }) {
            updatedFavorites.append(remote)
        }

        favoritedQuestions = updatedFavorites
        saveFavorites()
    }
}
