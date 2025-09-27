import SwiftUI

struct CategorySelectionView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        VStack {
            Text("Choose a Category")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.categories) { category in
                        if let categoryID = category.id {
                            NavigationLink(destination: QuestionView(category: category, questions: viewModel.questions[categoryID] ?? [])) {
                                CategoryCardView(category: category)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Progress indicator
            VStack {
                Text("162 / 312 questions viewed")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("Total questions in app: 4,455")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
    }
}

struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectionView()
    }
}
