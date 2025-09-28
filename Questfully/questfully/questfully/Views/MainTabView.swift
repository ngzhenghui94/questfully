import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var categoryViewModel: CategoryViewModel

    @State private var showPaywall: Bool = false
    @State private var pendingTabSelection: Int?

    var body: some View {
        TabView(selection: $viewModelSelection) {
            CategorySelectionView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Categories")
                }
                .tag(Tab.categories.rawValue)

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(Tab.favorites.rawValue)
            
            // Journey Themes tab gated behind premium
            randomTabContent
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Themes")
                }
                .tag(Tab.random.rawValue)
            
            ProfileView(authManager: authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile.rawValue)
        }
        .onChange(of: viewModelSelection) { oldValue, newValue in
            guard let tab = Tab(rawValue: newValue) else { return }
            if tab.requiresPremium && !subscriptionManager.isPremium {
                pendingTabSelection = newValue
                viewModelSelection = oldValue
                showPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView {
                showPaywall = false
                pendingTabSelection = nil
            } onContinueLimited: {
                showPaywall = false
                pendingTabSelection = nil
                subscriptionManager.resetToLimited()
            }
            .environmentObject(subscriptionManager)
        }
        .onChange(of: subscriptionManager.isPremium) { _, isPremium in
            guard isPremium else { return }
            showPaywall = false
            if let pending = pendingTabSelection {
                viewModelSelection = pending
                pendingTabSelection = nil
            }
        }
        .onChange(of: subscriptionManager.shouldPresentPaywall) { _, shouldPresent in
            guard shouldPresent else { return }
            pendingTabSelection = viewModelSelection
            showPaywall = true
            subscriptionManager.shouldPresentPaywall = false
        }
    }

    private var randomTabContent: some View {
        Group {
            if subscriptionManager.isPremium {
                JourneyThemesView()
            } else {
                PremiumUnlockView(title: "Journey Themes are Premium",
                                  message: "Upgrade to unlock curated conversation journeys and more!",
                                  actionTitle: "Unlock Premium") {
                    pendingTabSelection = Tab.random.rawValue
                    showPaywall = true
                }
            }
        }
    }

    @State private var viewModelSelection: Int = Tab.categories.rawValue

    private enum Tab: Int {
        case categories
        case favorites
        case random
        case profile

        var requiresPremium: Bool {
            switch self {
            case .random:
                return true
            default:
                return false
            }
        }
    }
}
