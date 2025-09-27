import SwiftUI

struct QuestionView: View {
    let category: Category
    let questions: [Question]
    
    @State private var currentIndex = 0
    @State private var randomizedQuestions: [Question] = []
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset: CGFloat = 0

    private let headerSpacing: CGFloat = 16

    var body: some View {
        ZStack {
            Color(hex: category.color).edgesIgnoringSafeArea(.all)
            VStack {
                header
                Spacer()
                questionContent
                    .padding(.horizontal)
                    .gesture(swipeGesture)
                Spacer()
                footer
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(spacing: headerSpacing) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
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

            Button(action: randomizeQuestions) {
                Image(systemName: "die.face.5")
                    .foregroundColor(.white)
                    .font(.title2)
            }

            Button(action: toggleFavorite) {
                if let question = currentQuestion {
                    let isFavorite = favoritesManager.isFavorited(question)
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                        .font(.title2)
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.white)
                        .font(.title2)
                        .opacity(0)
                }
            }
            .disabled(currentQuestion == nil)
        }
        .padding([.horizontal, .top])
    }

    private var questionContent: some View {
        Group {
            if let question = currentQuestion {
                Text(question.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .offset(x: dragOffset)
                    .animation(.easeInOut(duration: 0.2), value: dragOffset)
            } else {
                Text("No questions in this category yet.")
                    .foregroundColor(.white)
            }
        }
    }

    private var footer: some View {
        Group {
            if let _ = currentQuestion {
                VStack {
                    ProgressView(value: Double(currentIndex + 1), total: Double(questionCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .padding()

                    HStack {
                        Button(action: moveToPreviousQuestion) {
                            Text("Previous")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .leading)
                        }
                        .disabled(currentIndex == 0)

                        Spacer()

                        Text("\(currentIndex + 1) of \(questionCount)")
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: moveToNextQuestion) {
                            Text("Next")
                                .foregroundColor(.white)
                                .frame(width: 100, alignment: .trailing)
                        }
                        .disabled(currentIndex == questionCount - 1)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom)
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 80
                if value.translation.width < -threshold {
                    moveToNextQuestion()
                } else if value.translation.width > threshold {
                    moveToPreviousQuestion()
                }
            }
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

    private func moveToPreviousQuestion() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    private func moveToNextQuestion() {
        if currentIndex < questionCount - 1 {
            currentIndex += 1
        }
    }

    private func shareQuestion() {
        guard let question = currentQuestion else { return }
        let activityVC = UIActivityViewController(activityItems: [question.text], applicationActivities: nil)
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        if let windowScene = scene as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true)
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

    private func randomizeQuestions() {
        randomizedQuestions = questions.shuffled()
        currentIndex = 0
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
