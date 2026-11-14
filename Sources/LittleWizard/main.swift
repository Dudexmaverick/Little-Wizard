
import Gtk
import Cairo
import Foundation
import GLib

// MARK: - Estado do jogo

let game = GameState()

// Relogio compartilhado pelas animacoes
let animationClock = ProcessInfo.processInfo.systemUptime

// MARK: - Aplicacao

let status = Application.run(startupHandler: nil) { app in

    // Janela principal

    let window = ApplicationWindowRef(application: app)
    window.title = "Little Wizard — Potion Lab"
    window.setDefaultSize(width: 960, height: 720)

    // Layout

    let layout = BoxRef(
        orientation: .vertical,
        spacing: 10
    )

    // Titulo

    let title = LabelRef(
        str: "🧙 LITTLE WIZARD — POTION LAB 🧪"
    )
    layout.append(child: title)

    // Placar

    let scoreLabel = LabelRef(
        str: "Pontos: 0 | Moedas: 0 | Receitas: 0/3"
    )
    layout.append(child: scoreLabel)

    // Area grafica

    let drawingArea = DrawingAreaRef()

    drawingArea.setSizeRequest(
        width: 850,
        height: 430
    )
    drawingArea.setHexpand(expand: true)
    drawingArea.setVexpand(expand: true)

    drawingArea.setDrawFunc { _, context, width, height in
        let elapsed =
            ProcessInfo.processInfo.systemUptime
            - animationClock

        GameRenderer.draw(
            context: context,
            width: width,
            height: height,
            animationTime: elapsed
        )
    }

    layout.append(child: drawingArea)

    // Mensagens

    let messageLabel = LabelRef(str: game.message)
    layout.append(child: messageLabel)

    // Atualizacao da interface

    let refresh = {
        scoreLabel.setText(
            str: "Pontos: \(game.score) | Moedas: \(game.coins) | Receitas: \(game.discovered.count)/3"
        )

        messageLabel.setText(str: game.message)
        drawingArea.queueDraw()
    }

    // MARK: - Ingredientes

    let ingredients = BoxRef(
        orientation: .horizontal,
        spacing: 8
    )

    let flower = ButtonRef(label: "🌸 Flor lunar")
    let crystal = ButtonRef(label: "💎 Cristal azul")
    let mushroom = ButtonRef(label: "🍄 Cogumelo")
    let herb = ButtonRef(label: "🌿 Erva mistica")

    flower.onClicked { _ in
        game.select(.flower)
        refresh()
    }

    crystal.onClicked { _ in
        game.select(.crystal)
        refresh()
    }

    mushroom.onClicked { _ in
        game.select(.mushroom)
        refresh()
    }

    herb.onClicked { _ in
        game.select(.herb)
        refresh()
    }

    ingredients.append(child: flower)
    ingredients.append(child: crystal)
    ingredients.append(child: mushroom)
    ingredients.append(child: herb)

    layout.append(child: ingredients)

    // MARK: - Preparar pocao e reiniciar

    let actions = BoxRef(
        orientation: .horizontal,
        spacing: 8
    )

    let brew = ButtonRef(label: "🧪 Preparar pocao")

    brew.onClicked { _ in
        game.brew()
        refresh()
    }

    let restart = ButtonRef(label: "🔄 Reiniciar")

    restart.onClicked { _ in
        game.restart()
        refresh()
    }

    actions.append(child: brew)
    actions.append(child: restart)

    layout.append(child: actions)

    // MARK: - Exibir janela

    window.set(child: layout)
    window.set(visible: true)

    // MARK: - Loop de animacao

    // Aproximadamente 30 quadros por segundo.
    // Atualiza maguinho e caldeirao juntos.

    timeout(add: 33) {
        drawingArea.queueDraw()
        return true
    }
}

print(
    "Little Wizard encerrado: \(String(describing: status))"
)
