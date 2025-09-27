import Foundation

class APIService {
    let baseURL = "http://127.0.0.1:8080"

    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                completion(.success(categories))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchQuestions(for categoryID: UUID, completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories/\(categoryID)/questions") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let questions = try JSONDecoder().decode([Question].self, from: data)
                completion(.success(questions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
