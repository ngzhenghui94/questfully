import SwiftUI

struct QuestionView: View {
    let category: Category
    let questions: [Question]
    
    @State private var currentIndex = 0
    @State private var randomizedQuestions: [Question] = []
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
                        if let question = currentQuestion {
                            Image(systemName: favoritesManager.isFavorited(question) ? "heart.fill" : "heart")
                                .foregroundColor(favoritesManager.isFavorited(question) ? .red : .white)
                                .font(.title2)
                        }
                    }
                    .disabled(currentQuestion == nil)
                    .opacity(currentQuestion == nil ? 0 : 1)
                    .padding(.leading)
                }
                .padding()

                Spacer()

                // Question Text
                if let question = currentQuestion {
                    Text(question.text)
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
                if let question = currentQuestion {
                    VStack {
                        // Progress Bar
                        ProgressView(value: Double(currentIndex + 1), total: Double(questionCount))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .padding()

                        // Navigation
                        HStack(alignment: .center) {
                            Button(action: {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }) {
                                Text("Previous")
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                            }
                            .disabled(currentIndex == 0)

                            Spacer(minLength: 0)

                            Text("\(currentIndex + 1) of \(questionCount)")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)

                            Spacer(minLength: 0)

                            Button(action: {
                                if currentIndex < questionCount - 1 {
                                    currentIndex += 1
                                }
                            }) {
                                Text("Next")
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .disabled(currentIndex == questionCount - 1)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var currentQuestion: Question? {
        guard !randomizedQuestions.isEmpty else {
            return questions.isEmpty ? nil : questions[currentIndex]
        }
        return randomizedQuestions[currentIndex]
    }

    private var questionCount: Int {
        randomizedQuestions.isEmpty ? questions.count : randomizedQuestions.count
    }

    private func shareQuestion() {
        guard let question = currentQuestion else { return }
        let questionText = question.text
        let activityVC = UIActivityViewController(activityItems: [questionText], applicationActivities: nil)
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

    private func toggleFavorite() {
        guard let question = currentQuestion else { return }
        if favoritesManager.isFavorited(question) {
            favoritesManager.removeFavorite(question)
        } else {
            favoritesManager.addFavorite(question)
        }
    }

    init(category: Category, questions: [Question]) {
        self.category = category
        self.questions = questions
        self._randomizedQuestions = State(initialValue: questions.shuffled())
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(category: Category(id: UUID(), name: "Deep Questions", color: "8E44AD"),
                     questions: [Question(id: UUID(), text: "What is a belief you hold with which many people disagree?", categoryId: UUID())])
            .environmentObject(FavoritesManager())
    }
}
