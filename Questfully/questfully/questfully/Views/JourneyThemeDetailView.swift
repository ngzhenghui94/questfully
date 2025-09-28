import SwiftUI

struct JourneyThemeDetailView: View {
    @EnvironmentObject private var themesViewModel: JourneyThemesViewModel
    let theme: JourneyTheme
    let deviceId: String
    let userId: String?

    @State private var currentStepIndex: Int = 0
    @State private var isLoadingProgress: Bool = true

    init(theme: JourneyTheme, deviceId: String = "preview-device", userId: String? = nil) {
        self.theme = theme
        self.deviceId = deviceId
        self.userId = userId
    }

    var body: some View {
        Group {
            if isLoadingProgress {
                ProgressView()
            } else {
                VStack(spacing: 0) {
                    TabView(selection: $currentStepIndex) {
                        ForEach(Array(theme.steps.enumerated()), id: \.offset) { index, step in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 24) {
                                    header

                                    stepCard(step)
                                }
                                .padding()
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))

                    journeyControls
                }
            }
        }
        .navigationTitle(theme.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await themesViewModel.loadProgress(for: theme, deviceId: deviceId, userId: userId)
            if let progress = themesViewModel.progressByTheme[theme.id] {
                currentStepIndex = max(0, min(progress.currentStep - 1, theme.steps.count - 1))
            }
            isLoadingProgress = false
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: theme.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.indigo)

                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.title)
                        .font(.title.bold())
                    Text(theme.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(theme.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func stepCard(_ step: JourneyTheme.Step) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.title)
                .font(.headline)

            Text(step.prompt.text)
                .font(.body)

            if let category = themesViewModel.category(for: step.prompt) {
                Text(category.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let reflection = step.reflection {
                Divider()
                Text("Reflection")
                    .font(.caption.uppercaseSmallCaps())
                    .foregroundStyle(.secondary)
                Text(reflection)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var journeyControls: some View {
        HStack(spacing: 12) {
            Button {
                if currentStepIndex > 0 {
                    currentStepIndex -= 1
                    persistProgress()
                }
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(currentStepIndex == 0)

            Button {
                if currentStepIndex < theme.steps.count - 1 {
                    currentStepIndex += 1
                    persistProgress()
                } else {
                    currentStepIndex = theme.steps.count - 1
                    persistProgress(completed: true)
                }
            } label: {
                Label(currentStepIndex == theme.steps.count - 1 ? "Finish" : "Next", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
    }

    private func persistProgress(completed: Bool? = nil) {
        let targetStep = currentStepIndex + 1
        let isCompleted = completed ?? (themesViewModel.progressByTheme[theme.id]?.completed ?? false)
        Task {
            await themesViewModel.updateProgress(for: theme,
                                                deviceId: deviceId,
                                                userId: userId,
                                                currentStep: targetStep,
                                                completed: isCompleted)
        }
    }
}

struct JourneyThemeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuestion = Question(id: UUID(), text: "What made you smile today?", categoryId: UUID())
        let sampleSteps = [
            JourneyTheme.Step(title: "Step 1", prompt: sampleQuestion, reflection: "Note a highlight from the conversation.")
        ]

        return JourneyThemeDetailView(
            theme: JourneyTheme(
                slug: "sample-theme",
                title: "Sample",
                subtitle: "Preview",
                description: "Description",
                icon: "sparkles",
                steps: sampleSteps
            )
        )
    }
}


