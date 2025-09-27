import Foundation

final class LocalDataStore {
    static let shared = LocalDataStore()

    private let fileManager: FileManager
    private let queue: DispatchQueue
    private let baseDirectory: URL
    private let categoriesURL: URL
    private let questionsURL: URL
    private let statsURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.queue = DispatchQueue(label: "com.questfully.LocalDataStore", qos: .utility)

        var directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        directory.appendPathComponent("QuestfullyCache", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("LocalDataStore: Failed to create cache directory - \(error.localizedDescription)")
            }
        }

        self.baseDirectory = directory
        self.categoriesURL = directory.appendingPathComponent("categories.json")
        self.questionsURL = directory.appendingPathComponent("questions.json")
        self.statsURL = directory.appendingPathComponent("stats.json")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func loadCategories() -> [Category] {
        queue.sync {
            guard fileManager.fileExists(atPath: categoriesURL.path) else { return [] }
            do {
                let data = try Data(contentsOf: categoriesURL)
                return try decoder.decode([Category].self, from: data)
            } catch {
                print("LocalDataStore: Failed to load categories - \(error.localizedDescription)")
                return []
            }
        }
    }

    func loadQuestions() -> [UUID: [Question]] {
        queue.sync {
            guard fileManager.fileExists(atPath: questionsURL.path) else { return [:] }
            do {
                let data = try Data(contentsOf: questionsURL)
                let buckets = try decoder.decode(CachedQuestions.self, from: data)
                var map: [UUID: [Question]] = [:]
                for bucket in buckets.items {
                    map[bucket.categoryId] = bucket.questions
                }
                return map
            } catch {
                print("LocalDataStore: Failed to load questions - \(error.localizedDescription)")
                return [:]
            }
        }
    }

    func loadStats() -> AppStats? {
        queue.sync {
            guard fileManager.fileExists(atPath: statsURL.path) else { return nil }
            do {
                let data = try Data(contentsOf: statsURL)
                return try decoder.decode(AppStats.self, from: data)
            } catch {
                print("LocalDataStore: Failed to load stats - \(error.localizedDescription)")
                return nil
            }
        }
    }

    func save(categories: [Category]) {
        queue.async {
            do {
                let data = try self.encoder.encode(categories)
                try data.write(to: self.categoriesURL, options: .atomic)
            } catch {
                print("LocalDataStore: Failed to save categories - \(error.localizedDescription)")
            }
        }
    }

    func save(questions: [UUID: [Question]]) {
        queue.async {
            let buckets = CachedQuestions(items: questions.map { CachedQuestions.Entry(categoryId: $0.key, questions: $0.value) })
            do {
                let data = try self.encoder.encode(buckets)
                try data.write(to: self.questionsURL, options: .atomic)
            } catch {
                print("LocalDataStore: Failed to save questions - \(error.localizedDescription)")
            }
        }
    }

    func save(stats: AppStats) {
        queue.async {
            do {
                let data = try self.encoder.encode(stats)
                try data.write(to: self.statsURL, options: .atomic)
            } catch {
                print("LocalDataStore: Failed to save stats - \(error.localizedDescription)")
            }
        }
    }

    private struct CachedQuestions: Codable {
        let items: [Entry]

        struct Entry: Codable {
            let categoryId: UUID
            let questions: [Question]
        }
    }
}

