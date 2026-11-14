import Foundation

enum Ingredient: String, CaseIterable {
    case flower = "Flor lunar"
    case crystal = "Cristal azul"
    case mushroom = "Cogumelo"
    case herb = "Erva mistica"
}

final class GameState {
    var selected: [Ingredient] = []
    var discovered: Set<String> = []
    var score = 0
    var coins = 0
    var message = "Escolha dois ingredientes para o caldeirao!"

    func select(_ ingredient: Ingredient) {
        if selected.contains(ingredient) {
            selected.removeAll { $0 == ingredient }
        } else if selected.count < 2 {
            selected.append(ingredient)
        } else {
            message = "O caldeirao aceita apenas dois ingredientes."
            return
        }
        message = selected.isEmpty ? "Escolha dois ingredientes!" : "Ingredientes: " + selected.map(\.rawValue).joined(separator: " + ")
    }

    func brew() {
        guard selected.count == 2 else {
            message = "Selecione exatamente dois ingredientes."
            return
        }
        let combination = Set(selected)
        let result: String?
        if combination == Set([.flower, .crystal]) { result = "Pocao da Lua" }
        else if combination == Set([.mushroom, .herb]) { result = "Pocao de Cura" }
        else if combination == Set([.crystal, .herb]) { result = "Pocao de Mana" }
        else { result = nil }

        if let result {
            if discovered.insert(result).inserted {
                score += 50
                coins += 10
                message = "✨ \(result)! +50 pontos, +10 moedas!"
            } else {
                message = "✨ \(result)! Receita ja descoberta."
            }
        } else {
            message = "💨 Mistura misteriosa! Tente outra combinacao."
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
