import Foundation
import AuthenticationServices

@MainActor
final class AuthManager: NSObject, ObservableObject {
    enum AuthState {
        case signedOut
        case signingIn
        case signedIn(UserSession)
        case error(String)
    }

    struct UserSession: Equatable {
        let userId: String
        let displayName: String?
        let sessionToken: String
        let expiresAt: Date
    }

    @Published private(set) var state: AuthState

    private let apiService: APIService
    private let keychain = KeychainHelper()

    private enum KeychainKeys {
        static let sessionToken = "questfully.auth.sessionToken"
        static let userId = "questfully.auth.userId"
        static let displayName = "questfully.auth.displayName"
        static let expiresAt = "questfully.auth.expiresAt"
    }

    override init() {
        self.apiService = APIService()
        if let session = AuthManager.restoreSession(using: KeychainHelper()) {
            self.state = .signedIn(session)
            self.apiService.updateSessionToken(session.sessionToken)
        } else {
            self.state = .signedOut
        }
        super.init()
    }

    func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            state = .error(error.localizedDescription)
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8),
                  let authorizationCodeData = credential.authorizationCode,
                  let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
                state = .error("Unable to parse Apple ID credential")
                return
            }

            state = .signingIn

            apiService.signInWithApple(identityToken: identityToken,
                                       authorizationCode: authorizationCode,
                                       fullName: credential.fullName?.formatted()) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self?.state = .error(error.localizedDescription)
                    case .success(let response):
                        guard response.success else {
                            self?.state = .error("Authentication failed.")
                            return
                        }
                        let session = UserSession(userId: response.userId,
                                                  displayName: response.displayName,
                                                  sessionToken: response.sessionToken,
                                                  expiresAt: response.expiresAt)
                        self?.persist(session: session)
                        self?.apiService.updateSessionToken(response.sessionToken)
                        self?.state = .signedIn(session)
                    }
                }
            }
        }
    }

    func signOut() {
        guard case let .signedIn(session) = state else { return }
        apiService.logout(sessionToken: session.sessionToken) { _ in }
        clearSession()
        state = .signedOut
    }

    private func persist(session: UserSession) {
        keychain.set(session.sessionToken, forKey: KeychainKeys.sessionToken)
        keychain.set(session.userId, forKey: KeychainKeys.userId)
        keychain.set(session.displayName ?? "", forKey: KeychainKeys.displayName)
        keychain.set(session.expiresAt.timeIntervalSince1970.description, forKey: KeychainKeys.expiresAt)
    }

    private func clearSession() {
        keychain.remove(forKey: KeychainKeys.sessionToken)
        keychain.remove(forKey: KeychainKeys.userId)
        keychain.remove(forKey: KeychainKeys.displayName)
        keychain.remove(forKey: KeychainKeys.expiresAt)
        apiService.updateSessionToken(nil)
    }

    private static func restoreSession(using keychain: KeychainHelper) -> UserSession? {
        guard let token = keychain.get(forKey: KeychainKeys.sessionToken),
              let userId = keychain.get(forKey: KeychainKeys.userId),
              let expiresRaw = keychain.get(forKey: KeychainKeys.expiresAt),
              let expiresInterval = TimeInterval(expiresRaw) else {
            return nil
        }

        let displayName = keychain.get(forKey: KeychainKeys.displayName)
        let expiresAt = Date(timeIntervalSince1970: expiresInterval)

        guard expiresAt > Date() else {
            keychain.remove(forKey: KeychainKeys.sessionToken)
            keychain.remove(forKey: KeychainKeys.userId)
            keychain.remove(forKey: KeychainKeys.displayName)
            keychain.remove(forKey: KeychainKeys.expiresAt)
            return nil
        }

        return UserSession(userId: userId, displayName: displayName, sessionToken: token, expiresAt: expiresAt)
    }
}

final class KeychainHelper {
    func set(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain: Failed to store value for key \(key) with status \(status)")
        }
    }

    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    func remove(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

