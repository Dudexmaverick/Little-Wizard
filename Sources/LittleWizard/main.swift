
import Gtk
import Cairo
import Foundation
import GLib

let game = GameState()
let animationClock = ProcessInfo.processInfo.systemUptime

var brewing = false
var brewStartedAt = 0.0
var activePotionColor = "turquoise"
var brewingSelection: [String] = []

let brewDuration = 2.4

let status = Application.run(startupHandler: nil) { app in

    let window = ApplicationWindowRef(application: app)
    window.title = "Little Wizard — Potion Lab"
    window.setDefaultSize(width: 1240, height: 720)

    // MARK: - Layout principal

    let layout = BoxRef(
        orientation: .horizontal,
        spacing: 0
    )

    // MARK: - Cenario

    let drawingArea = DrawingAreaRef()
    drawingArea.setSizeRequest(width: 800, height: 600)
    drawingArea.setHexpand(expand: true)
    drawingArea.setVexpand(expand: true)

    var sceneWidth = 800.0
    var sceneHeight = 600.0

    drawingArea.setDrawFunc { _, context, width, height in

        sceneWidth = Double(width)
        sceneHeight = Double(height)

        let elapsed =
            ProcessInfo.processInfo.systemUptime
            - animationClock

        let progress = brewing
            ? min(
                1.0,
                (ProcessInfo.processInfo.systemUptime
                    - brewStartedAt) / brewDuration
            )
            : -1.0

        GameRenderer.draw(
            context: context,
            width: width,
            height: height,
            animationTime: elapsed,
            brewProgress: progress,
            potionColor: activePotionColor,
            selectedIngredients: game.selected.map(\.rawValue),
            brewingIngredients: brewing
                ? brewingSelection
                : []
        )
    }

    layout.append(child: drawingArea)

    // MARK: - Barra lateral

    let sidebar = BoxRef(
        orientation: .vertical,
        spacing: 14
    )

    sidebar.setSizeRequest(width: 330, height: -1)

    let heading = LabelRef(
        str: "🧪 MESA DE ALQUIMIA"
    )

    let subtitle = LabelRef(
        str: "✨ Little Wizard · Potion Lab ✨"
    )

    sidebar.append(child: heading)
    sidebar.append(child: subtitle)

    // MARK: - Estatisticas

    let stats = BoxRef(
        orientation: .vertical,
        spacing: 10
    )

    let scoreLabel = LabelRef(str: "⭐ Pontos: 0")
    let coinsLabel = LabelRef(str: "🪙 Moedas: 0")
    let recipesLabel = LabelRef(
        str: "📖 Receitas: 0/\(game.totalRecipes)"
    )

    stats.append(child: scoreLabel)
    stats.append(child: coinsLabel)
    stats.append(child: recipesLabel)

    sidebar.append(child: stats)

    // MARK: - Ingredientes

    let ingredientsHeading = LabelRef(
        str: "✨ INGREDIENTES SELECIONADOS"
    )

    let firstIngredient = LabelRef(
        str: "① Escolha um ingrediente"
    )

    let secondIngredient = LabelRef(
        str: "② Escolha outro ingrediente"
    )

    sidebar.append(child: ingredientsHeading)
    sidebar.append(child: firstIngredient)
    sidebar.append(child: secondIngredient)

    // MARK: - Estado da pocao

    let panelStatus = LabelRef(
        str: "🌙 Aguardando ingredientes..."
    )

    sidebar.append(child: panelStatus)

    // MARK: - Botoes

    let prepareButton = ButtonRef(
        label: "🧪 PREPARAR POÇÃO"
    )

    let restartButton = ButtonRef(
        label: "🔄 Reiniciar partida"
    )

    sidebar.append(child: prepareButton)
    sidebar.append(child: restartButton)

    // MARK: - Mensagens

    let messageHeading = LabelRef(
        str: "📜 MENSAGEM DO MAGUINHO"
    )

    let messageLabel = LabelRef(
        str: game.message
    )

    sidebar.append(child: messageHeading)
    sidebar.append(child: messageLabel)

    layout.append(child: sidebar)

    // MARK: - Atualizacao da interface

    let refresh = {

        scoreLabel.setText(
            str: "⭐ Pontos: \(game.score)"
        )

        coinsLabel.setText(
            str: "🪙 Moedas: \(game.coins)"
        )

        recipesLabel.setText(
            str: "📖 Receitas: \(game.discovered.count)/\(game.totalRecipes)"
        )

        let selected = game.selected.map(\.rawValue)

        firstIngredient.setText(
            str: selected.count > 0
                ? "① \(selected[0])"
                : "① Escolha um ingrediente"
        )

        secondIngredient.setText(
            str: selected.count > 1
                ? "② \(selected[1])"
                : "② Escolha outro ingrediente"
        )

        panelStatus.setText(
            str: brewing
                ? "✨ Preparando poção..."
                : (
                    selected.count == 2
                    ? "🟢 Pronto para preparar!"
                    : "🌙 Aguardando ingredientes..."
                )
        )

        messageLabel.setText(str: game.message)
        drawingArea.queueDraw()
    }

    // MARK: - Preparar pocao

    let preparePotion = {

        guard !brewing else { return }

        guard game.selected.count == 2 else {
            game.message = "Escolha dois ingredientes."
            refresh()
            return
        }

        if let recipe = PotionLibrary.find(
            ingredients: game.selected
        ) {
            activePotionColor = recipe.color
        } else {
            activePotionColor = "mystery"
        }

        brewingSelection = game.selected.map(\.rawValue)

        brewStartedAt =
            ProcessInfo.processInfo.systemUptime

        brewing = true

        game.message =
            "✨ O maguinho esta preparando a pocao!"

        refresh()
    }

    prepareButton.onClicked { _ in
        preparePotion()
    }

    restartButton.onClicked { _ in

        guard !brewing else { return }

        game.restart()
        activePotionColor = "turquoise"
        brewingSelection.removeAll()

        refresh()
    }

    // MARK: - Inventario clicavel

    let ingredientOrder: [Ingredient] = [
        .flower,
        .crystal,
        .mushroom,
        .herb
    ]

    let clickController = InventoryClick(
        area: drawingArea
    ) { x, y in

        guard !brewing else { return }

        let slotSize = 52.0
        let gap = 12.0
        let totalWidth = slotSize * 4 + gap * 3

        let left = (sceneWidth - totalWidth) / 2
        let top = sceneHeight * 0.835

        guard y >= top,
              y <= top + slotSize else {
            return
        }

        for index in 0..<4 {

            let slotX =
                left + Double(index) * (slotSize + gap)

            if x >= slotX &&
               x <= slotX + slotSize {

                game.select(ingredientOrder[index])
                refresh()
                break
            }
        }
    }

    // MARK: - Iniciar janela

    withExtendedLifetime(clickController) {
        window.set(child: layout)
        window.set(visible: true)
    }

    // MARK: - Animacoes

    timeout(add: 33) {

        if brewing {

            let elapsed =
                ProcessInfo.processInfo.systemUptime
                - brewStartedAt

            if elapsed >= brewDuration {

                game.brew()

                brewing = false
                brewingSelection.removeAll()

                refresh()
            }
        }

        drawingArea.queueDraw()
        return true
    }
}

print(
    "Little Wizard encerrado: \(String(describing: status))"
)
