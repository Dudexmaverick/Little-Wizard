import Gtk
import Cairo
import Foundation
import GLib

// MARK: - Estado do jogo

let game = GameState()

let animationClock = ProcessInfo.processInfo.systemUptime

var brewing = false
var brewStartedAt = 0.0
var activePotionColor = "turquoise"
var brewingSelection: [String] = []

let brewDuration = 2.4

// MARK: - Aplicacao

let status = Application.run(startupHandler: nil) { app in

    let window = ApplicationWindowRef(application: app)

    window.title = "Little Wizard — Potion Lab"
    window.setDefaultSize(width: 960, height: 650)

    let layout = BoxRef(
        orientation: .vertical,
        spacing: 10
    )

    let title = LabelRef(
        str: "🧙 LITTLE WIZARD — POTION LAB 🧪"
    )

    layout.append(child: title)

    let scoreLabel = LabelRef(
        str: "Pontos: 0 | Moedas: 0 | Receitas: 0/\(game.totalRecipes)"
    )

    layout.append(child: scoreLabel)

    // MARK: - Area grafica

    let drawingArea = DrawingAreaRef()

    drawingArea.setSizeRequest(
        width: 850,
        height: 430
    )

    drawingArea.setHexpand(expand: true)
    drawingArea.setVexpand(expand: true)

    var sceneWidth = 850.0
    var sceneHeight = 430.0

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

    // MARK: - Mensagens

    let messageLabel = LabelRef(str: game.message)

    layout.append(child: messageLabel)

    let refresh = {
        scoreLabel.setText(
            str: "Pontos: \(game.score) | Moedas: \(game.coins) | Receitas: \(game.discovered.count)/\(game.totalRecipes)"
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

        let combination = Set(game.selected)

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

    // MARK: - Janela de alquimia

    var alchemyWindow: ApplicationWindowRef?

    let showAlchemyWindow = {

        guard !brewing else { return }
        guard game.selected.count == 2 else { return }

        if let existing = alchemyWindow {
            existing.set(visible: false)
        }

        let popup = ApplicationWindowRef(application: app)

        popup.title = "🧪 Mesa de Alquimia"
        popup.setDefaultSize(width: 380, height: 220)

        let popupLayout = BoxRef(
            orientation: .vertical,
            spacing: 12
        )

        let heading = LabelRef(
            str: "✨ PREPARAR POCAO? ✨"
        )

        popupLayout.append(child: heading)

        let selectedText = game.selected
            .map(\.rawValue)
            .joined(separator: " + ")

        let selectedLabel = LabelRef(
            str: selectedText
        )

        popupLayout.append(child: selectedLabel)

        let buttons = BoxRef(
            orientation: .horizontal,
            spacing: 12
        )

        let prepare = ButtonRef(
            label: "🧪 Preparar pocao"
        )

        let restart = ButtonRef(
            label: "🔄 Reiniciar"
        )

        prepare.onClicked { _ in
            popup.set(visible: false)
            preparePotion()
        }

        restart.onClicked { _ in
            popup.set(visible: false)

            game.restart()
            activePotionColor = "turquoise"
            brewingSelection.removeAll()

            refresh()
        }

        buttons.append(child: prepare)
        buttons.append(child: restart)

        popupLayout.append(child: buttons)

        popup.set(child: popupLayout)
        popup.set(visible: true)

        alchemyWindow = popup
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

        // Coordenadas utilizadas pelo GameRenderer.
        let slotSize = 52.0
        let gap = 12.0

        let totalWidth =
            slotSize * 4 + gap * 3

        let left =
            (sceneWidth - totalWidth) / 2

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

                if game.selected.count == 2 {
                    showAlchemyWindow()
                }

                break
            }
        }
    }

    // Mantem o controlador vivo durante a execucao.
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
