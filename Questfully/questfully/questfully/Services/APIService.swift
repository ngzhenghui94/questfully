import Foundation

class APIService {
    let baseURL = "http://127.0.0.1:8080"

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private var sessionToken: String?

    func updateSessionToken(_ token: String?) {
        sessionToken = token
    }

    private func buildRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token = sessionToken {
            request.addValue(token, forHTTPHeaderField: "X-Session-Token")
        }
        return request
    }

    func fetchFavorites(deviceId: String, completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/favorites/\(deviceId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let questions = try self.decoder.decode([Question].self, from: data)
                completion(.success(questions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func addFavorite(deviceId: String, questionId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/favorites") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let payload: [String: Any] = [
            "deviceId": deviceId,
            "questionId": questionId.uuidString
        ]

        do {
            let body = try JSONSerialization.data(withJSONObject: payload, options: [])
            let request = buildRequest(url: url, method: "POST", body: body)
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func removeFavorite(deviceId: String, questionId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/favorites") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let payload: [String: Any] = [
            "deviceId": deviceId,
            "questionId": questionId.uuidString
        ]

        do {
            let body = try JSONSerialization.data(withJSONObject: payload, options: [])
            let request = buildRequest(url: url, method: "DELETE", body: body)
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let categories = try self.decoder.decode([Category].self, from: data)
                completion(.success(categories))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchCategories() async -> Result<[Category], Error> {
        await withCheckedContinuation { continuation in
            fetchCategories { result in
                continuation.resume(returning: result)
            }
        }
    }

    func fetchQuestions(for categoryID: UUID, completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories/\(categoryID)/questions") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let questions = try self.decoder.decode([Question].self, from: data)
                completion(.success(questions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchQuestions(for categoryID: UUID) async -> Result<[Question], Error> {
        await withCheckedContinuation { continuation in
            fetchQuestions(for: categoryID) { result in
                continuation.resume(returning: result)
            }
        }
    }

    func fetchStats(completion: @escaping (Result<AppStats, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/stats") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let stats = try self.decoder.decode(AppStats.self, from: data)
                completion(.success(stats))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchStats() async -> Result<AppStats, Error> {
        await withCheckedContinuation { continuation in
            fetchStats { result in
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - Journey Themes

    func fetchJourneyThemes(completion: @escaping (Result<[JourneyThemeDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/journey-themes") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let themes = try JSONDecoder().decode([JourneyThemeDTO].self, from: data)
                completion(.success(themes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchJourneyThemes() async -> Result<[JourneyThemeDTO], Error> {
        await withCheckedContinuation { continuation in
            fetchJourneyThemes { result in
                continuation.resume(returning: result)
            }
        }
    }

    func fetchJourneyProgress(slug: String, deviceId: String, userId: String? = nil) async -> Result<JourneyProgressDTO, Error> {
        var components = URLComponents(string: "\(baseURL)/journey-themes/\(slug)/progress")
        var queryItems = [URLQueryItem(name: "deviceId", value: deviceId)]
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            return .failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
        }

        var request = buildRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return .failure(parseServerError(data: data, response: http))
            }

            let progress = try decoder.decode(JourneyProgressDTO.self, from: data)
            return .success(progress)
        } catch {
            return .failure(error)
        }
    }

    func upsertJourneyProgress(slug: String, payload: JourneyProgressUpdateDTO) async -> Result<JourneyProgressDTO, Error> {
        guard let url = URL(string: "\(baseURL)/journey-themes/\(slug)/progress") else {
            return .failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
        }

        var request = buildRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? encoder.encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return .failure(parseServerError(data: data, response: http))
            }

            let progress = try decoder.decode(JourneyProgressDTO.self, from: data)
            return .success(progress)
        } catch {
            return .failure(error)
        }
    }

    func fetchQuestionCount(for categoryID: UUID, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories/\(categoryID)/count") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let countResponse = try self.decoder.decode(CountResponse.self, from: data)
                completion(.success(countResponse.count))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let request = buildRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let profile = try self.decoder.decode(UserProfile.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func updateProfile(_ profile: UserProfileUpdate, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        do {
            let body = try encoder.encode(profile)
            let request = buildRequest(url: url, method: "POST", body: body)
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func signInWithApple(identityToken: String, authorizationCode: String, fullName: String?, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/apple") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let payload = AppleSignInRequest(identityToken: identityToken, authorizationCode: authorizationCode, fullName: fullName)

        do {
            let body = try encoder.encode(payload)
            let request = buildRequest(url: url, method: "POST", body: body)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                    return
                }

                do {
                    let authResponse = try self.decoder.decode(AuthResponse.self, from: data)
                    completion(.success(authResponse))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func logout(sessionToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        do {
            let body = try JSONSerialization.data(withJSONObject: ["sessionToken": sessionToken], options: [])
            let request = buildRequest(url: url, method: "POST", body: body)
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

    private struct CountResponse: Codable {
        let count: Int
    }

    struct UserProfile: Codable {
        let displayName: String?
        let totalQuestions: Int
        let totalCategories: Int
        let totalFavorites: Int
        let perCategory: [CategoryStats]

        struct CategoryStats: Codable, Identifiable {
            let categoryId: UUID
            let totalQuestions: Int

            var id: UUID { categoryId }
        }
    }

    struct UserProfileUpdate: Codable {
        let displayName: String
    }

    struct AppleSignInRequest: Codable {
        let identityToken: String
        let authorizationCode: String
        let fullName: String?
    }

    struct AuthResponse: Codable {
        let success: Bool
        let userId: String
        let sessionToken: String
        let expiresAt: Date
        let displayName: String?
    }

    struct JourneyThemeDTO: Codable {
        let id: UUID
        let slug: String
        let title: String
        let subtitle: String
        let description: String
        let icon: String
        let steps: [JourneyThemeStepDTO]
    }

    struct JourneyThemeStepDTO: Codable {
        let id: UUID
        let title: String
        let reflection: String?
        let question: Question
        let order: Int
    }

    struct JourneyProgressDTO: Codable {
        let id: UUID?
        let themeId: UUID
        let currentStep: Int
        let completed: Bool
        let updatedAt: Date?
    }

    struct JourneyProgressUpdateDTO: Codable {
        let deviceId: String
        let userId: String?
        let currentStep: Int
        let completed: Bool
    }

    private struct APIErrorResponse: Codable {
        let error: String
    }

    private func parseServerError(data: Data, response: HTTPURLResponse) -> Error {
        if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
            return NSError(domain: "APIService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: apiError.error])
        }

        if let message = String(data: data, encoding: .utf8), !message.isEmpty {
            return NSError(domain: "APIService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        return NSError(domain: "APIService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server response (\(response.statusCode))"])
    }
}
