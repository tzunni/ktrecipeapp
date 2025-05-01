import SwiftUI

struct IngredientsListView: View {
    let ingredients: [String]

    var body: some View {
        NavigationView {
            List(ingredients, id: \.self) { ingredient in
                Text(ingredient)
            }.navigationTitle("Ingredients")
        }
    }
}

struct DetailedRecipeView: View {
    let recipe: Recipe
    @State private var showingIngredients = false

    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                if recipe.isAssetImage, let imageName = recipe.imagePath {
                    Image(imageName).resizable().scaledToFit().cornerRadius(10).padding()
                } else if let imagePath = recipe.imagePath, let image = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: image).resizable().scaledToFit().cornerRadius(10).padding()
                } else {
                    Rectangle().fill(Color.gray).frame(height: 200).cornerRadius(10).padding()
                }

                Text(recipe.title).font(.largeTitle).fontWeight(.bold).padding(.horizontal)

                Text(recipe.description).font(.body).padding(.horizontal)

                Text("Steps:").font(.headline).padding(.horizontal)

                ForEach(recipe.steps, id: \.self) { step in
                    Text("- \(step)").font(.body).padding(.horizontal)
                }
            }
        }.navigationTitle("Recipe Details").overlay(
            Button(action: {
                showingIngredients = true
            }) {
                Image(systemName: "list.bullet").foregroundColor(.white).padding().background(Color.blue.opacity(0.7)).clipShape(Circle())
            }.padding(),
            alignment:.bottomTrailing
        ).sheet(isPresented: $showingIngredients) {
            IngredientsListView(ingredients: recipe.ingredients.map { "\($0.name): \($0.quantity)" })
        }
    }
}
