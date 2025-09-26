import SwiftUI

struct MainTabView: View {
    @ObservedObject var favoritesManager: FavoritesManager

    var body: some View {
        TabView {
            CategorySelectionView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Categories")
                }

            FavoritesView(favoritedQuestions: $favoritesManager.favoritedQuestions)
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
            
            Text("Profile View")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
