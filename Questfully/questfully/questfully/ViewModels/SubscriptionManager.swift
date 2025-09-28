import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    enum Plan: String, CaseIterable {
        case annual = "questfully.premium.annual"
        case monthly = "questfully.premium.monthly"

        var displayName: String {
            switch self {
            case .annual: return "Yearly"
            case .monthly: return "Monthly"
            }
        }
    }

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var questionsConsumedToday: Int = 0
    @Published var shouldPresentPaywall: Bool = false
    @Published private(set) var totalQuestionsViewed: Int = 0
    @Published private(set) var availableProducts: [Product] = []

    let dailyQuestionLimit = 15

    private let userDefaults: UserDefaults
    private let calendar: Calendar
    private let quotaCountKey = "questfully.subscription.dailyCount"
    private let quotaDateKey = "questfully.subscription.dailyDate"
    private let totalCountKey = "questfully.subscription.totalCount"
    private var updatesTask: Task<Void, Never>? = nil

    init(userDefaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        refreshDailyQuotaIfNeeded()
        totalQuestionsViewed = userDefaults.integer(forKey: totalCountKey)

        Task {
            await loadProducts()
            await listenForTransactions()
            await updatePremiumStatusFromEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            let productIDs = Set(Plan.allCases.map { $0.rawValue })
            availableProducts = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    func purchase(plan: Plan) async {
        guard !isProcessing else { return }
        guard let product = availableProducts.first(where: { $0.id == plan.rawValue }) else {
            errorMessage = "Plan unavailable."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                try await handleTransactionVerification(verification)
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePremiumStatusFromEntitlements()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    func resetToLimited() {
        isPremium = false
        refreshDailyQuotaIfNeeded(forceReset: true)
        shouldPresentPaywall = false
    }

    func canViewAnotherQuestion() -> Bool {
        isPremium || questionsConsumedToday < dailyQuestionLimit
    }

    @discardableResult
    func registerQuestionView() -> Bool {
        refreshDailyQuotaIfNeeded()

        if isPremium {
            totalQuestionsViewed += 1
            persistQuotaState()
            return true
        }

        guard questionsConsumedToday < dailyQuestionLimit else {
            return false
        }

        questionsConsumedToday += 1
        totalQuestionsViewed += 1
        persistQuotaState()
        return true
    }

    func showPaywallAfterQuotaReached() {
        guard !isPremium else { return }
        shouldPresentPaywall = true
    }

    private func refreshDailyQuotaIfNeeded(forceReset: Bool = false) {
        let now = Date()
        let savedDate = userDefaults.object(forKey: quotaDateKey) as? Date

        if forceReset || savedDate == nil || !calendar.isDate(savedDate!, inSameDayAs: now) {
            questionsConsumedToday = 0
            userDefaults.set(now, forKey: quotaDateKey)
            userDefaults.set(0, forKey: quotaCountKey)
        } else {
            let storedCount = userDefaults.integer(forKey: quotaCountKey)
            questionsConsumedToday = min(storedCount, dailyQuestionLimit)
        }
        totalQuestionsViewed = userDefaults.integer(forKey: totalCountKey)
    }

    private func persistQuotaState() {
        userDefaults.set(questionsConsumedToday, forKey: quotaCountKey)
        userDefaults.set(Date(), forKey: quotaDateKey)
        userDefaults.set(totalQuestionsViewed, forKey: totalCountKey)
    }

    private func listenForTransactions() async {
        updatesTask = Task.detached(priority: .background) { [weak self] in
            for await verification in Transaction.updates {
                await self?.handleTransactionUpdate(verification)
            }
        }
    }

    private func handleTransactionUpdate(_ verification: VerificationResult<Transaction>) async {
        do {
            try await handleTransactionVerification(verification)
        } catch {
            await MainActor.run { [weak self] in
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    private func handleTransactionVerification(_ verification: VerificationResult<Transaction>) async throws {
        switch verification {
        case .unverified(_, let error):
            throw error
        case .verified(let transaction):
            await MainActor.run { [weak self] in
                if transaction.revocationDate == nil && transaction.expirationDate ?? .distantFuture > Date() {
                    self?.isPremium = true
                    self?.shouldPresentPaywall = false
                } else {
                    self?.isPremium = false
                }
            }
            await transaction.finish()
        }
    }

    private func updatePremiumStatusFromEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case let .verified(transaction) = result,
               Plan.allCases.map({ $0.rawValue }).contains(transaction.productID),
               transaction.revocationDate == nil,
               transaction.expirationDate ?? .distantFuture > Date() {
                await MainActor.run {
                    self.isPremium = true
                    self.shouldPresentPaywall = false
                }
                return
            }
        }

        await MainActor.run {
            self.isPremium = false
        }
    }
}


