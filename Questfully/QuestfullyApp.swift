import SwiftUI

@main
struct QuestfullyApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            MainTabView(favoritesManager: favoritesManager)
        }
    }
}
