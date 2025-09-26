import SwiftUI

struct FavoritesView: View {
    @Binding var favoritedQuestions: [Question]

    var body: some View {
        NavigationView {
            VStack {
                if favoritedQuestions.isEmpty {
                    Text("No favorited questions yet.")
                        .foregroundColor(.gray)
                } else {
                    List(favoritedQuestions) { question in
                        Text(question.text)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
