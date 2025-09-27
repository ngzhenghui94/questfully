import SwiftUI

@main
struct QuestfullyApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authManager)
                .environmentObject(favoritesManager)
        }
    }
}
