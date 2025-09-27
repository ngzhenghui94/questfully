import SwiftUI

struct CategorySelectionView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Choose a Category")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                TabView(selection: $viewModel.focusedCategoryID) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(destination: QuestionView(category: category, questions: viewModel.questions[category.id] ?? [])) {
                            CategoryCardView(category: category)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal, 40)
                        }
                        .tag(category.id as UUID?)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 420)
                .onChange(of: viewModel.focusedCategoryID) { _, newValue in
                    viewModel.updateFocusedCategory(to: newValue)
                }
                .onChange(of: viewModel.categories) { _, newCategories in
                    if viewModel.focusedCategoryID == nil {
                        viewModel.updateFocusedCategory(to: newCategories.first?.id)
                    }
                }
                
                Spacer()
                
                // Progress indicator
                VStack {
                    if let totalForCategory = viewModel.focusedCategoryQuestionCount {
                        Text("\(totalForCategory) questions in this category")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text("Total questions in app: \(viewModel.stats?.totalQuestions ?? 0)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Categories available: \(viewModel.stats?.totalCategories ?? 0)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView("Loading stats…")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.bottom, 4)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectionView()
    }
}
