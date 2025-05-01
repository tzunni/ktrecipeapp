import SwiftUI
import UIKit

// MARK: - Recipe Model

struct Ingredient: Codable, Identifiable {
    let id: UUID
    let name: String
    let quantity: String

    init(id: UUID = UUID(), name: String, quantity: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}

struct Recipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imagePath: String?
    let isAssetImage: Bool
    let ingredients: [Ingredient] // List of ingredients with quantities
    let steps: [String]

    init(id: UUID = UUID(), title: String, description: String, imagePath: String?, isAssetImage: Bool = false, ingredients: [Ingredient] = [], steps: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.imagePath = imagePath
        self.isAssetImage = isAssetImage
        self.ingredients = ingredients
        self.steps = steps
    }
}

// MARK: - Recipe Manager

class RecipeManager: ObservableObject {
    @Published var recipes: [Recipe] = []

    private let key = "saved_recipes"

    init() {
        loadRecipes()
    }

    func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            self.recipes = decoded
        } else {
            self.recipes = [
                Recipe(
                    title: "Spaghetti Carbonara",
                    description: "Classic Italian pasta with eggs, cheese, pancetta, and pepper.",
                    imagePath: "spaghetti",
                    isAssetImage: true,
                    ingredients: [
                        Ingredient(name: "Spaghetti", quantity: "200g"),
                        Ingredient(name: "Eggs", quantity: "2"),
                        Ingredient(name: "Cheese", quantity: "50g"),
                        Ingredient(name: "Pancetta", quantity: "100g"),
                        Ingredient(name: "Pepper", quantity: "to taste")
                    ],
                    steps: [
                        "Bring a large pot of salted water to a boil.",
                        "Add spaghetti and cook until al dente, about 8-10 minutes.",
                        "Meanwhile, cook pancetta in a skillet over medium heat until crispy.",
                        "Beat eggs in a bowl and mix with grated cheese.",
                        "Drain pasta, reserving some cooking water.",
                        "Quickly toss hot pasta with egg mixture, adding reserved water as needed to create a creamy sauce.",
                        "Add pancetta and season with pepper.",
                        "Serve immediately with additional cheese on top."
                    ]
                ),
                Recipe(
                    title: "Avocado Toast",
                    description: "Simple and healthy avocado toast with seasoning.",
                    imagePath: "avocado_toast",
                    isAssetImage: true,
                    ingredients: [
                        Ingredient(name: "Avocado", quantity: "1"),
                        Ingredient(name: "Bread", quantity: "2 slices"),
                        Ingredient(name: "Salt", quantity: "to taste"),
                        Ingredient(name: "Pepper", quantity: "to taste"),
                        Ingredient(name: "Lemon Juice", quantity: "1 tsp")
                    ],
                    steps: [
                        "Toast bread slices until golden brown.",
                        "Cut avocado in half, remove pit, and scoop flesh into a bowl.",
                        "Mash avocado with a fork and season with salt, pepper, and lemon juice.",
                        "Spread mashed avocado evenly on toasted bread slices.",
                        "Optional: Top with additional toppings like sliced radishes, cherry tomatoes, or a sprinkle of seeds.",
                        "Serve immediately."
                    ]
                )
            ]
        }
    }

    func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }

    func deleteRecipe(at index: Int) {
        recipes.remove(at: index)
        saveRecipes()
    }
}

// MARK: - Main View with Grid

struct MainView: View {
    @StateObject private var recipeManager = RecipeManager()
    @State private var showingAddRecipe = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(recipeManager.recipes.enumerated()), id: \.1.id) { index, recipe in
                        RecipeCardView(recipe: recipe).contextMenu {
                            Button(role:.destructive) {
                                recipeManager.deleteRecipe(at: index)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }.padding()
            }.navigationTitle("Recipes").toolbar {
                ToolbarItem(placement:.navigationBarTrailing) {
                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }.sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(recipeManager: recipeManager)
            }.background(Color("celeste"))
        }
    }
}

// MARK: - Recipe Card View

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        NavigationLink(destination: DetailedRecipeView(recipe: recipe)) {
            VStack(alignment:.leading) {
                if recipe.isAssetImage, let imageName = recipe.imagePath {
                    Image(imageName).resizable().scaledToFill().frame(height: 120).frame(width: 150).clipped().cornerRadius(10)
                } else if let imagePath = recipe.imagePath, let image = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: image).resizable().scaledToFill().frame(height: 120).frame(width: 150).clipped().cornerRadius(10)
                } else {
                    Rectangle().fill(Color.gray).frame(height: 120).frame(width: 150).cornerRadius(10)
                }

                Text(recipe.title).font(.headline).padding(.top, 5)

                Text(recipe.description).font(.caption).foregroundColor(.secondary).lineLimit(2)

                Text("Ingredients: \(recipe.ingredients.count) items").font(.footnote).foregroundColor(.secondary).padding(.top, 2)
            }.padding().background(Color(.systemBackground)).cornerRadius(15).shadow(radius: 3).frame(width: 150).frame(height: 250)
        }
    }
}

// MARK: - Image Picker Wrapper

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Add Recipe View

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeManager: RecipeManager

    @State private var title = ""
    @State private var description = ""
    @State private var ingredientName = ""
    @State private var ingredientQuantity = ""
    @State private var ingredients: [Ingredient] = []
    @State private var stepsText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Section(header: Text("Ingredients")) {
                        HStack {
                            TextField("Ingredient Name", text: $ingredientName)
                            TextField("Quantity", text: $ingredientQuantity)
                            Button("Add") {
                                if !ingredientName.isEmpty && !ingredientQuantity.isEmpty {
                                    let newIngredient = Ingredient(name: ingredientName, quantity: ingredientQuantity)
                                    ingredients.append(newIngredient)
                                    ingredientName = ""
                                    ingredientQuantity = ""
                                }
                            }
                        }
                        
                        List {
                            ForEach(ingredients) { ingredient in
                                Text("\(ingredient.name): \(ingredient.quantity)")
                            }
                        }
                    }
                    
                    Section(header: Text("Steps")) {
                        TextField("Steps (comma separated)", text: $stepsText)
                    }

                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Image")
                    }

                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage).resizable().scaledToFit().frame(height: 150).cornerRadius(10).padding(.top)
                    }
                }
            }.navigationTitle("Add Recipe").toolbar {
                ToolbarItem(placement:.cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement:.confirmationAction) {
                    Button("Save") {
                        if let selectedImage = selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                            let imagePath = saveImageToDocuments(imageData: imageData)
                            let newRecipe = Recipe(
                                title: title,
                                description: description,
                                imagePath: imagePath,
                                isAssetImage: false,
                                ingredients: ingredients,
                                steps: stepsText.split(separator: ",").map { $0.trimmingCharacters(in:.whitespaces) }
                            )
                            recipeManager.addRecipe(newRecipe)
                            dismiss()
                        }
                    }.disabled(title.isEmpty || description.isEmpty || selectedImage == nil)
                }
            }.sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }

    func saveImageToDocuments(imageData: Data) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)[0].appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
