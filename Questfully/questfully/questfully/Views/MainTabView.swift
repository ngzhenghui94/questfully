import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        TabView {
            CategorySelectionView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Categories")
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
            
            // Placeholder for other tabs
            Text("Deck View")
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Decks")
                }
            
            ProfileView(authManager: authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
