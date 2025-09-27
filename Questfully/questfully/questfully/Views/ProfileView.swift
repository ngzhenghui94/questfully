import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @ObservedObject var authManager: AuthManager

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

            Text("Use your Apple ID to sync favorites across devices and access profile stats.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            SignInWithAppleButtonView(authManager: authManager)
                .frame(height: 45)
                .padding(.horizontal)
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
        }
        .listStyle(.insetGrouped)
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
        ProfileView()
    }
}

