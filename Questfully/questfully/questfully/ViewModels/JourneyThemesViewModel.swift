import Foundation

@MainActor
final class JourneyThemesViewModel: ObservableObject {
    @Published private(set) var themes: [JourneyTheme] = []
    @Published private(set) var progressByTheme: [UUID: JourneyThemeProgress] = [:]
    @Published private(set) var isLoading: Bool = false

    private let dataStore: ContentDataStore
    private var allCategories: [Category] = []

    init(dataStore: ContentDataStore) {
        self.dataStore = dataStore
        loadThemes()
    }

    func loadThemes() {
        isLoading = true

        Task {
            await dataStore.refreshContent()
            await fetchThemesFromAPI()
        }
    }

    func category(for question: Question) -> Category? {
        allCategories.first { category in
            dataStore.questions(for: category.id).contains(where: { $0.id == question.id })
        }
    }

    func refreshProgress(for deviceId: String, userId: String? = nil) async {
        guard !themes.isEmpty else { return }
        for theme in themes {
            await loadProgress(for: theme, deviceId: deviceId, userId: userId)
        }
    }

    func loadProgress(for theme: JourneyTheme, deviceId: String, userId: String? = nil) async {
        let result = await dataStore.apiClient.fetchJourneyProgress(slug: theme.slug,
                                                                    deviceId: deviceId,
                                                                    userId: userId)
        switch result {
        case .success(let dto):
            await MainActor.run {
                progressByTheme[theme.id] = JourneyThemeProgress(id: dto.id,
                                                                  themeId: dto.themeId,
                                                                  currentStep: dto.currentStep,
                                                                  completed: dto.completed,
                                                                  updatedAt: dto.updatedAt)
            }
        case .failure(let error):
            print("JourneyThemesViewModel: Failed to load progress - \(error.localizedDescription)")
        }
    }

    func updateProgress(for theme: JourneyTheme,
                        deviceId: String,
                        userId: String? = nil,
                        currentStep: Int,
                        completed: Bool) async {
        let payload = APIService.JourneyProgressUpdateDTO(deviceId: deviceId,
                                                          userId: userId,
                                                          currentStep: currentStep,
                                                          completed: completed)

        let previous = progressByTheme[theme.id]
        await MainActor.run {
            progressByTheme[theme.id] = JourneyThemeProgress(id: previous?.id,
                                                              themeId: theme.id,
                                                              currentStep: currentStep,
                                                              completed: completed,
                                                              updatedAt: Date())
        }

        let result = await dataStore.apiClient.upsertJourneyProgress(slug: theme.slug, payload: payload)
        switch result {
        case .success(let dto):
            await MainActor.run {
                progressByTheme[theme.id] = JourneyThemeProgress(id: dto.id,
                                                                  themeId: dto.themeId,
                                                                  currentStep: dto.currentStep,
                                                                  completed: dto.completed,
                                                                  updatedAt: dto.updatedAt)
            }
        case .failure(let error):
            print("JourneyThemesViewModel: Failed to update progress - \(error.localizedDescription)")
            if let previous = previous {
                await MainActor.run {
                    progressByTheme[theme.id] = previous
                }
            }
        }
    }

    private func fetchThemesFromAPI() async {
        let categories = dataStore.categories
        await MainActor.run {
            self.allCategories = categories
        }

        let result = await dataStore.apiClient.fetchJourneyThemes()

        switch result {
        case .success(let dtos):
            let themes = mapThemes(from: dtos)
            await MainActor.run {
                self.themes = themes
                self.isLoading = false
            }
        case .failure:
            await MainActor.run {
                self.themes = []
                self.isLoading = false
            }
        }
    }

    private func mapThemes(from dtos: [APIService.JourneyThemeDTO]) -> [JourneyTheme] {
        dtos.map { dto in
            let steps = dto.steps.sorted(by: { $0.order < $1.order }).map { step in
                JourneyTheme.Step(id: step.id,
                                  title: step.title,
                                  prompt: step.question,
                                  reflection: step.reflection)
            }

            return JourneyTheme(id: dto.id,
                                 slug: dto.slug,
                                 title: dto.title,
                                 subtitle: dto.subtitle,
                                 description: dto.description,
                                 icon: dto.icon,
                                 steps: steps)
        }
    }
}


