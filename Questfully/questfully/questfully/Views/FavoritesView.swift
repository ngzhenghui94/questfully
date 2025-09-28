import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    private let backgroundGradient = LinearGradient(
        colors: [Color(.systemGray6), Color(.systemBackground)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                if favoritesManager.favoritedQuestions.isEmpty {
                    FavoritesEmptyStateView()
                        .padding(.horizontal, 32)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(favoritesManager.favoritedQuestions) { question in
                                FavoriteQuestionCard(question: question) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        favoritesManager.removeFavorite(question)
                                    }
                                }
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        .padding(.vertical, 28)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

private struct FavoriteQuestionCard: View {
    let question: Question
    let onRemove: () -> Void

    private static let gradients: [LinearGradient] = [
        LinearGradient(colors: [Color(hex: "8E44AD"), Color(hex: "9B59B6")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "3498DB"), Color(hex: "2ECC71")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "E67E22"), Color(hex: "E74C3C")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "16A085"), Color(hex: "27AE60")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "34495E"), Color(hex: "2C3E50")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "1ABC9C"), Color(hex: "2980B9")], startPoint: .topLeading, endPoint: .bottomTrailing)
    ]

    private var gradient: LinearGradient {
        let rawValue = question.id.uuidString.hashValue
        let index = Int(rawValue.magnitude) % Self.gradients.count
        return Self.gradients[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Favorited", systemImage: "heart.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "heart.slash")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white.opacity(0.15))
                        )
                }
                .accessibilityLabel("Remove from favorites")
            }

            Text(question.text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)

            Text("Pin this prompt for your next great conversation.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 12)
    }
}

private struct FavoritesEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "9B59B6"))

            Text("Save Your First Favorite")
                .font(.title3.weight(.semibold))
                .foregroundColor(Color.primary.opacity(0.85))

            Text("Mark questions you love with the heart icon to keep them handy here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 12)
    }
}
