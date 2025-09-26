import SwiftUI

struct QuestionView: View {
    let category: Category
    let questions: [Question]
    
    @State private var currentIndex = 0
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(hex: category.color).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    Button(action: shareQuestion) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Button(action: toggleFavorite) {
                        Image(systemName: favoritesManager.isFavorited(questions[currentIndex]) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorited(questions[currentIndex]) ? .red : .white)
                            .font(.title2)
                    }
                    .padding(.leading)
                }
                .padding()

                Spacer()

                // Question Text
                if !questions.isEmpty {
                    Text(questions[currentIndex].text)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("No questions in this category yet.")
                        .foregroundColor(.white)
                }


                Spacer()

                // Footer
                if !questions.isEmpty {
                    VStack {
                        // Progress Bar
                        ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .padding()

                        // Navigation
                        HStack {
                            Button(action: {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }) {
                                Text("Previous")
                                    .foregroundColor(.white)
                            }
                            .disabled(currentIndex == 0)

                            Spacer()
                            
                            Text("\(currentIndex + 1) of \(questions.count)")
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: {
                                if currentIndex < questions.count - 1 {
                                    currentIndex += 1
                                }
                            }) {
                                Text("Next")
                                    .foregroundColor(.white)
                            }
                            .disabled(currentIndex == questions.count - 1)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func shareQuestion() {
        guard !questions.isEmpty else { return }
        let questionText = questions[currentIndex].text
        let activityVC = UIActivityViewController(activityItems: [questionText], applicationActivities: nil)
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

    private func toggleFavorite() {
        guard !questions.isEmpty else { return }
        let question = questions[currentIndex]
        if favoritesManager.isFavorited(question) {
            favoritesManager.removeFavorite(question)
        } else {
            favoritesManager.addFavorite(question)
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(category: Category(id: "1", name: "Deep Questions", color: "8E44AD"),
                     questions: [Question(id: "q1", text: "What is a belief you hold with which many people disagree?", categoryId: "1")])
            .environmentObject(FavoritesManager())
    }
}
