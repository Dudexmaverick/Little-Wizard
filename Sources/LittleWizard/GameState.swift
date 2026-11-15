import Foundation

enum Ingredient: String, CaseIterable, Hashable {
    case flower = "Flor lunar"
    case crystal = "Cristal azul"
    case mushroom = "Cogumelo"
    case herb = "Erva mistica"
}

struct PotionRecipe {
    let name: String
    let ingredients: Set<Ingredient>
    let description: String
    let color: String
}

enum PotionLibrary {
    static let recipes: [PotionRecipe] = [
        PotionRecipe(
            name: "Pocao da Lua",
            ingredients: [.flower, .crystal],
            description: "Uma mistura iluminada pela magia lunar.",
            color: "moon"
        ),
        PotionRecipe(
            name: "Pocao de Cura",
            ingredients: [.mushroom, .herb],
            description: "Restaura a energia com a magia da floresta.",
            color: "healing"
        ),
        PotionRecipe(
            name: "Pocao de Mana",
            ingredients: [.crystal, .herb],
            description: "Recarrega o poder dos feiticos.",
            color: "mana"
        ),
        PotionRecipe(
            name: "Pocao dos Sonhos",
            ingredients: [.flower, .mushroom],
            description: "Desperta sonhos e visoes encantadas.",
            color: "moon"
        ),
        PotionRecipe(
            name: "Pocao da Natureza",
            ingredients: [.flower, .herb],
            description: "Conecta o mago a energia da natureza.",
            color: "healing"
        ),
        PotionRecipe(
            name: "Pocao das Sombras",
            ingredients: [.crystal, .mushroom],
            description: "Revela os misterios da magia sombria.",
            color: "mystery"
        )
    ]

    static func find(
        ingredients: [Ingredient]
    ) -> PotionRecipe? {
        let combination = Set(ingredients)
        return recipes.first {
            $0.ingredients == combination
        }
    }
}

final class GameState {
    var selected: [Ingredient] = []
    var discovered: Set<String> = []
    var score = 0
    var coins = 0
    var message = "Escolha dois ingredientes para o caldeirao!"

    var totalRecipes: Int {
        PotionLibrary.recipes.count
    }

    func select(_ ingredient: Ingredient) {
        if selected.contains(ingredient) {
            selected.removeAll { $0 == ingredient }
        } else if selected.count < 2 {
            selected.append(ingredient)
        } else {
            message = "Escolha apenas dois ingredientes."
            return
        }

        if selected.isEmpty {
            message = "Escolha dois ingredientes!"
        } else {
            message = "Ingredientes: " +
                selected.map(\.rawValue).joined(separator: " + ")
        }
    }

    func brew() {
        guard selected.count == 2 else {
            message = "Selecione exatamente dois ingredientes."
            return
        }

        if let recipe = PotionLibrary.find(ingredients: selected) {
            if discovered.insert(recipe.name).inserted {
                score += 50
                coins += 10
                message = "✨ \(recipe.name)! +50 pontos, +10 moedas!"
            } else {
                message = "✨ \(recipe.name)! Receita ja descoberta."
            }
        } else {
            message = "Mistura misteriosa!"
        }

        selected.removeAll()
    }

    func restart() {
        selected.removeAll()
        discovered.removeAll()
        score = 0
        coins = 0
        message = "Escolha dois ingredientes para o caldeirao!"
    }
}
