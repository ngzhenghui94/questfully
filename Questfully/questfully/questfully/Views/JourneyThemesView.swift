import SwiftUI

struct JourneyThemesView: View {
    @EnvironmentObject private var viewModel: JourneyThemesViewModel
    @EnvironmentObject private var favoritesManager: FavoritesManager

    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.themes.isEmpty {
                    ProgressView("Loading themes…")
                } else if viewModel.themes.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No themes yet", systemImage: "sparkles")
                    }, description: {
                        Text("We'll add curated journeys soon. Stay tuned!")
                    })
                } else {
                    List(viewModel.themes) { theme in
                        NavigationLink {
                            JourneyThemeDetailView(theme: theme,
                                                   deviceId: favoritesManager.deviceId,
                                                   userId: nil)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                themeRow(theme)
                                progressRow(theme)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await refreshContent()
                    }
                }
            }
            .navigationTitle("Journey Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task { await refreshContent() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(isRefreshing)
                    }
                }
            }
            .task {
                await viewModel.refreshProgress(for: favoritesManager.deviceId)
            }
        }
    }

    @ViewBuilder
    private func themeRow(_ theme: JourneyTheme) -> some View {
        HStack(spacing: 16) {
            Image(systemName: theme.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 4) {
                Text(theme.title)
                    .font(.headline)
                Text(theme.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func progressRow(_ theme: JourneyTheme) -> some View {
        let progress = viewModel.progressByTheme[theme.id]
        let currentStep = progress?.currentStep ?? 1
        let totalSteps = theme.steps.count
        let clampedCurrent = min(max(currentStep, 1), totalSteps)
        let fraction = Double(clampedCurrent - 1) / Double(max(totalSteps - 1, 1))

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if progress?.completed == true {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else {
                    Label("Step \(clampedCurrent) of \(totalSteps)", systemImage: "flag.checkered")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
            }

            ProgressView(value: fraction)
                .progressViewStyle(.linear)
        }
    }

    private func refreshContent() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        await viewModel.loadThemes()
        await viewModel.refreshProgress(for: favoritesManager.deviceId)
        isRefreshing = false
    }
}

struct JourneyThemesView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyThemesView()
    }
}


