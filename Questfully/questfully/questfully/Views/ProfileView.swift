import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @ObservedObject var authManager: AuthManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var categoryViewModel: CategoryViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    @ViewBuilder
    private var content: some View {
        switch authManager.state {
        case .signedOut:
            signInPrompt
        case .signingIn:
            ProgressView("Signing in…")
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error(let message):
            errorView(message: message)
        case .signedIn(let session):
            signedInView(session: session)
        }
    }

    private var signInPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.blue)

            Text("Sign in to personalize Questfully")
                .font(.title2)
                .fontWeight(.semibold)

            usageSummary

            SignInWithAppleButtonView(authManager: authManager)
                .frame(height: 45)
                .padding(.horizontal)

            Button(action: { Task { await subscriptionManager.restorePurchases() } }) {
                Text("Restore Purchases")
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text("Sign in failed")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            SignInWithAppleButtonView(authManager: authManager)
                .frame(height: 45)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private func signedInView(session: AuthManager.UserSession) -> some View {
        List {
            Section(header: Text("Account")) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.displayName ?? "Signed in")
                            .font(.headline)
                        Text("User ID: \(session.userId)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("Device ID: \(favoritesManager.deviceId)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                } icon: {
                    Image(systemName: "person.crop.circle")
                        .symbolRenderingMode(.hierarchical)
                }

                Button(role: .destructive) {
                    withAnimation {
                        authManager.signOut()
                    }
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }

            subscriptionSection
            usageSection
            actionsSection
        }
        .listStyle(.insetGrouped)
    }

    private var usageSummary: some View {
        VStack(spacing: 8) {
            Text("View up to \(subscriptionManager.dailyQuestionLimit) questions daily for free.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Viewed today: \(subscriptionManager.questionsConsumedToday) / \(subscriptionManager.dailyQuestionLimit)")
                .font(.footnote)
            Text("All-time viewed: \(subscriptionManager.totalQuestionsViewed)")
                .font(.footnote)
            Text("Favorites saved: \(favoritesManager.favoritedQuestions.count)")
                .font(.footnote)
            Text("Device ID: \(favoritesManager.deviceId)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var subscriptionSection: some View {
        Section(header: Text("Subscription")) {
            statRow(icon: subscriptionManager.isPremium ? "crown.fill" : "lock.fill",
                    title: subscriptionManager.isPremium ? "Premium Active" : "Free Plan",
                    value: subscriptionManager.isPremium ? "Unlimited" : "Limited")
                .foregroundStyle(subscriptionManager.isPremium ? .green : .orange)

            Text(subscriptionManager.isPremium
                 ? "You're enjoying Questfully Premium across all devices linked to your Apple ID."
                 : "Upgrade to unlock unlimited questions, sync, and exclusive content.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            statRow(icon: "gauge", title: "Daily Quota", value: "\(subscriptionManager.questionsConsumedToday)/\(subscriptionManager.dailyQuestionLimit)")

            ProgressView(value: Double(subscriptionManager.questionsConsumedToday), total: Double(subscriptionManager.dailyQuestionLimit))
        }
    }

    @ViewBuilder
    private var usageSection: some View {
        Section(header: Text("Usage")) {
            statRow(icon: "clock.fill", title: "Questions Viewed Today", value: "\(subscriptionManager.questionsConsumedToday)")
            statRow(icon: "chart.bar.fill", title: "All-time Viewed", value: "\(subscriptionManager.totalQuestionsViewed)")
            statRow(icon: "heart.fill", title: "Favorites", value: "\(favoritesManager.favoritedQuestions.count)")
            statRow(icon: "iphone", title: "Device ID", value: favoritesManager.deviceId)
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        Section(header: Text("Actions")) {
            if !subscriptionManager.isPremium {
                Button {
                    subscriptionManager.shouldPresentPaywall = true
                } label: {
                    Label("Unlock Premium", systemImage: "star.fill")
                }
            }

            Button {
                Task { await subscriptionManager.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        }
    }

    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

private struct SignInWithAppleButtonView: View {
    @ObservedObject var authManager: AuthManager

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            authManager.handleAuthorization(result)
        }
        .signInWithAppleButtonStyle(.black)
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(authManager: AuthManager())
    }
}

