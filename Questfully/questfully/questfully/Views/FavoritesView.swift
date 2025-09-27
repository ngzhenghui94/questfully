import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            VStack {
                if favoritesManager.favoritedQuestions.isEmpty {
                    Text("No favorited questions yet.")
                        .foregroundColor(.gray)
                } else {
                    List(favoritesManager.favoritedQuestions) { question in
                        Text(question.text)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
