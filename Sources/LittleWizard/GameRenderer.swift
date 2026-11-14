
import Foundation
import Cairo

struct GameRenderer {

    static func draw(
        context cr: Cairo.ContextRef,
        width: Int,
        height: Int,
        animationTime: Double
    ) {
        let w = Double(width)
        let h = Double(height)
        guard w > 0 && h > 0 else { return }

        let t = animationTime

        // MARK: - Parede do laboratorio

        cr.setSource(red: 0.11, green: 0.09, blue: 0.19)
        cr.rectangle(x: 0, y: 0, width: w, height: h)
        cr.fill()

        for row in 0..<Int(ceil(h / 48.0)) {
            for col in 0..<Int(ceil(w / 64.0)) + 1 {
                let offset = row.isMultiple(of: 2) ? 0.0 : 28.0
                let x = Double(col) * 64 - offset
                let y = Double(row) * 48

                cr.setSource(red: 0.18, green: 0.14, blue: 0.28)
                cr.rectangle(
                    x: x + 2, y: y + 2,
                    width: 59, height: 43
                )
                cr.fill()
            }
        }

        // Janela, lua e estrelas
        drawWindow(cr, x: w * 0.38, y: 22, time: t)

        // MARK: - Prateleiras

        cr.setSource(red: 0.34, green: 0.20, blue: 0.19)
        cr.rectangle(
            x: w * 0.08, y: h * 0.28,
            width: w * 0.25, height: 12
        )
        cr.rectangle(
            x: w * 0.68, y: h * 0.28,
            width: w * 0.25, height: 12
        )
        cr.fill()

        for i in 0..<4 {
            let x = w * 0.10 + Double(i) * 40

            drawBottle(
                cr, x: x, y: h * 0.28 - 42,
                color: i % 2 == 0
            )
            drawBottle(
                cr,
                x: w * 0.70 + Double(i) * 40,
                y: h * 0.28 - 42,
                color: i % 2 != 0
            )
        }

        // Livros na prateleira esquerda
        drawBooks(
            cr,
            x: w * 0.09,
            y: h * 0.28 - 43
        )

        // Cristal na prateleira direita
        drawCrystal(
            cr,
            x: w * 0.87,
            y: h * 0.28 - 27,
            time: t
        )

        // MARK: - Chao e mesa

        cr.setSource(red: 0.24, green: 0.16, blue: 0.22)
        cr.rectangle(
            x: 0, y: h * 0.80,
            width: w, height: h * 0.20
        )
        cr.fill()

        cr.setSource(red: 0.43, green: 0.25, blue: 0.23)
        cr.rectangle(
            x: w * 0.28, y: h * 0.73,
            width: w * 0.46, height: 22
        )
        cr.fill()

        // Velas animadas nas extremidades da mesa
        drawCandle(
            cr,
            x: w * 0.32,
            y: h * 0.73,
            time: t,
            phase: 0
        )

        drawCandle(
            cr,
            x: w * 0.69,
            y: h * 0.73,
            time: t,
            phase: 2.3
        )

        // Caldeirao e maguinho preservados
        drawCauldron(
            cr,
            cx: w * 0.52,
            cy: h * 0.62,
            time: t
        )

        drawWizard(
            cr,
            x: w * 0.20,
            y: h * 0.59,
            time: t
        )
    }

    // MARK: - Janela encantada

    private static func drawWindow(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double,
        time t: Double
    ) {
        // Moldura de madeira
        cr.setSource(red: 0.37, green: 0.22, blue: 0.27)
        cr.rectangle(x: x - 9, y: y - 9, width: 199, height: 153)
        cr.fill()

        // Ceu noturno
        cr.setSource(red: 0.055, green: 0.065, blue: 0.19)
        cr.rectangle(x: x, y: y, width: 181, height: 135)
        cr.fill()

        // Lua com brilho pulsante
        let glow = (sin(t * 1.2) + 1.0) / 2.0

        cr.setSource(
            red: 0.82, green: 0.84, blue: 1.0,
            alpha: 0.10 + glow * 0.15
        )
        cr.rectangle(
            x: x + 109, y: y + 17,
            width: 56, height: 56
        )
        cr.fill()

        cr.setSource(red: 0.97, green: 0.94, blue: 0.70)
        cr.rectangle(
            x: x + 119, y: y + 27,
            width: 36, height: 36
        )
        cr.fill()

        // Estrelas cintilantes
        for i in 0..<13 {
            let sx = x + 12 + Double((i * 37) % 156)
            let sy = y + 12 + Double((i * 23) % 107)
            let light = (sin(t * 2.0 + Double(i) * 1.7) + 1) / 2

            cr.setSource(
                red: 0.91, green: 0.92, blue: 1.0,
                alpha: 0.20 + light * 0.80
            )
            cr.rectangle(
                x: sx, y: sy,
                width: 3, height: 3
            )
            cr.fill()
        }

        // Divisorias da janela
        cr.setSource(red: 0.43, green: 0.27, blue: 0.25)
        cr.rectangle(x: x + 85, y: y, width: 11, height: 135)
        cr.rectangle(x: x, y: y + 68, width: 181, height: 9)
        cr.fill()

        // Peitoril
        cr.setSource(red: 0.55, green: 0.34, blue: 0.29)
        cr.rectangle(
            x: x - 17, y: y + 135,
            width: 215, height: 12
        )
        cr.fill()
    }

    // MARK: - Velas animadas

    private static func drawCandle(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double,
        time t: Double,
        phase: Double
    ) {
        let flicker = sin(t * 7.0 + phase) * 4.0
        let pulse = (sin(t * 5.0 + phase) + 1.0) / 2.0

        // Aura da chama
        cr.setSource(
            red: 1.0, green: 0.67, blue: 0.20,
            alpha: 0.07 + pulse * 0.10
        )
        cr.rectangle(
            x: x - 17, y: y - 82,
            width: 45, height: 61
        )
        cr.fill()

        // Cera
        cr.setSource(red: 0.91, green: 0.83, blue: 0.68)
        cr.rectangle(
            x: x - 3, y: y - 38,
            width: 19, height: 38
        )
        cr.fill()

        // Pavio
        cr.setSource(red: 0.19, green: 0.13, blue: 0.12)
        cr.rectangle(
            x: x + 5, y: y - 46,
            width: 3, height: 10
        )
        cr.fill()

        // Chama exterior
        cr.setSource(red: 1.0, green: 0.55, blue: 0.14)
        cr.moveTo(x - 1, y - 46)
        cr.lineTo(x + 6 + flicker, y - 70)
        cr.lineTo(x + 15, y - 46)
        cr.fill()

        // Centro da chama
        cr.setSource(red: 1.0, green: 0.92, blue: 0.40)
        cr.rectangle(
            x: x + 4 + flicker * 0.25,
            y: y - 52,
            width: 6, height: 12
        )
        cr.fill()
    }

    // MARK: - Livros de feiticos

    private static func drawBooks(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double
    ) {
        let colors: [(Double, Double, Double)] = [
            (0.60, 0.27, 0.70),
            (0.24, 0.54, 0.66),
            (0.70, 0.36, 0.28),
            (0.32, 0.62, 0.43)
        ]

        for i in 0..<4 {
            let bx = x + Double(i) * 13
            let bh = 31.0 + Double(i % 3) * 5.0
            let c = colors[i]

            cr.setSource(red: c.0, green: c.1, blue: c.2)
            cr.rectangle(
                x: bx, y: y + 43 - bh,
                width: 11, height: bh
            )
            cr.fill()

            // Detalhe dourado da lombada
            cr.setSource(red: 0.96, green: 0.77, blue: 0.35)
            cr.rectangle(
                x: bx + 2, y: y + 35,
                width: 7, height: 3
            )
            cr.fill()
        }
    }

    // MARK: - Cristal luminoso

    private static func drawCrystal(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double,
        time t: Double
    ) {
        let pulse = (sin(t * 2.3) + 1.0) / 2.0

        cr.setSource(
            red: 0.40, green: 0.85, blue: 1.0,
            alpha: 0.08 + pulse * 0.15
        )
        cr.rectangle(
            x: x - 13, y: y - 21,
            width: 38, height: 40
        )
        cr.fill()

        cr.setSource(red: 0.30, green: 0.73, blue: 0.91)
        cr.moveTo(x, y - 18)
        cr.lineTo(x + 17, y)
        cr.lineTo(x + 6, y + 16)
        cr.lineTo(x - 11, y + 1)
        cr.fill()

        cr.setSource(red: 0.70, green: 0.96, blue: 1.0)
        cr.rectangle(
            x: x + 1, y: y - 9,
            width: 4, height: 12
        )
        cr.fill()
    }

    // MARK: - Caldeirao animado

    private static func drawCauldron(
        _ cr: Cairo.ContextRef,
        cx: Double,
        cy: Double,
        time t: Double
    ) {
        let pulse = (sin(t * 2.4) + 1.0) / 2.0
        let wave = sin(t * 3.0) * 3.0

        cr.setSource(
            red: 0.18, green: 0.88, blue: 0.70,
            alpha: 0.08 + pulse * 0.15
        )
        cr.rectangle(
            x: cx - 108, y: cy - 47,
            width: 216, height: 128
        )
        cr.fill()

        cr.setSource(red: 0.08, green: 0.11, blue: 0.18)
        cr.rectangle(
            x: cx - 93, y: cy - 28,
            width: 186, height: 105
        )
        cr.fill()

        cr.setSource(red: 0.29, green: 0.36, blue: 0.48)
        cr.rectangle(
            x: cx - 80, y: cy - 12,
            width: 160, height: 76
        )
        cr.fill()

        cr.setSource(
            red: 0.25 + pulse * 0.12,
            green: 0.83 + pulse * 0.10,
            blue: 0.69
        )
        cr.rectangle(
            x: cx - 86, y: cy - 32 + wave,
            width: 172, height: 24
        )
        cr.fill()

        cr.setSource(red: 0.72, green: 1.0, blue: 0.86)
        cr.rectangle(
            x: cx - 52, y: cy - 26 + wave,
            width: 26, height: 8
        )
        cr.rectangle(
            x: cx + 22, y: cy - 26 + wave,
            width: 15, height: 8
        )
        cr.fill()

        // Bolhas ascendentes
        for i in 0..<9 {
            let speed = 19.0 + Double(i % 4) * 7.0
            let distance = (
                t * speed + Double(i) * 21.0
            ).truncatingRemainder(dividingBy: 130.0)

            let bx = cx - 60.0
                + Double((i * 37) % 120)
                + sin(t * 1.8 + Double(i)) * 7.0
            let by = cy - 34.0 - distance
            let size = Double(5 + (i % 3) * 2)
            let fade = max(0.12, 1.0 - distance / 130.0)

            cr.setSource(
                red: 0.50, green: 1.0, blue: 0.83,
                alpha: fade
            )
            cr.rectangle(
                x: bx, y: by,
                width: size, height: size
            )
            cr.fill()
        }

        // Particulas magicas
        for i in 0..<7 {
            let phase = t * 1.7 + Double(i) * 1.9
            let px = cx + sin(phase)
                * (65.0 + Double(i) * 4.0)
            let py = cy - 45.0 - Double(i % 4) * 24.0
            let sparkle = (sin(phase * 2.0) + 1.0) / 2.0

            cr.setSource(
                red: 0.91, green: 0.98, blue: 0.57,
                alpha: 0.15 + sparkle * 0.70
            )
            cr.rectangle(
                x: px, y: py,
                width: 4, height: 4
            )
            cr.fill()
        }
    }

    // MARK: - Maguinho animado

    private static func drawWizard(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double,
        time t: Double
    ) {
        let bob = sin(t * 2.0) * 3.0
        let wandMove = sin(t * 3.0) * 9.0
        let blinkPhase = t.truncatingRemainder(
            dividingBy: 5.0
        )
        let blinking = blinkPhase > 4.72 && blinkPhase < 4.90
        let wy = y + bob

        // Sombra
        cr.setSource(
            red: 0.05, green: 0.04, blue: 0.10,
            alpha: 0.50
        )
        cr.rectangle(
            x: x - 45, y: y + 109,
            width: 95, height: 8
        )
        cr.fill()

        // Capa
        cr.setSource(red: 0.44, green: 0.25, blue: 0.72)
        cr.rectangle(
            x: x - 40, y: wy + 10,
            width: 80, height: 100
        )
        cr.fill()

        // Faixa
        cr.setSource(red: 0.30, green: 0.16, blue: 0.55)
        cr.rectangle(
            x: x - 40, y: wy + 54,
            width: 80, height: 9
        )
        cr.fill()

        // Fivela
        cr.setSource(red: 0.98, green: 0.79, blue: 0.30)
        cr.rectangle(
            x: x - 7, y: wy + 52,
            width: 14, height: 13
        )
        cr.fill()

        // Bracos
        cr.setSource(red: 0.40, green: 0.21, blue: 0.65)
        cr.rectangle(
            x: x - 51, y: wy + 20,
            width: 16, height: 51
        )
        cr.rectangle(
            x: x + 34, y: wy + 17,
            width: 16, height: 40
        )
        cr.rectangle(
            x: x + 44,
            y: wy + 9 + wandMove * 0.3,
            width: 14, height: 15
        )
        cr.fill()

        // Maos
        cr.setSource(red: 0.90, green: 0.72, blue: 0.58)
        cr.rectangle(
            x: x - 50, y: wy + 65,
            width: 14, height: 13
        )
        cr.rectangle(
            x: x + 46,
            y: wy + 3 + wandMove * 0.3,
            width: 12, height: 13
        )
        cr.fill()

        // Varinha
        let wandX = x + 52
        let wandY = wy + 7 + wandMove * 0.3

        cr.setSource(red: 0.55, green: 0.32, blue: 0.18)
        cr.rectangle(
            x: wandX,
            y: wandY - 48 + wandMove,
            width: 6, height: 55
        )
        cr.fill()

        cr.setSource(red: 1.0, green: 0.88, blue: 0.40)
        cr.rectangle(
            x: wandX - 4,
            y: wandY - 57 + wandMove,
            width: 14, height: 14
        )
        cr.fill()

        // Faiscas da varinha
        for i in 0..<5 {
            let phase = t * 3.0 + Double(i) * 1.3
            let sx = wandX + 3 + sin(phase) * 24.0
            let sy = wandY - 50 + wandMove
                + cos(phase) * 21.0
            let opacity = 0.30
                + (sin(phase * 2.0) + 1.0) * 0.35

            cr.setSource(
                red: 1.0, green: 0.88, blue: 0.46,
                alpha: opacity
            )
            cr.rectangle(
                x: sx, y: sy,
                width: 5, height: 5
            )
            cr.fill()
        }

        // Rosto
        cr.setSource(red: 0.90, green: 0.72, blue: 0.58)
        cr.rectangle(
            x: x - 24, y: wy - 32,
            width: 48, height: 48
        )
        cr.fill()

        // Bochechas
        cr.setSource(red: 0.92, green: 0.54, blue: 0.57)
        cr.rectangle(
            x: x - 22, y: wy + 1,
            width: 8, height: 5
        )
        cr.rectangle(
            x: x + 14, y: wy + 1,
            width: 8, height: 5
        )
        cr.fill()

        // Olhos piscando
        cr.setSource(red: 0.07, green: 0.07, blue: 0.12)

        if blinking {
            cr.rectangle(
                x: x - 15, y: wy - 10,
                width: 9, height: 2
            )
            cr.rectangle(
                x: x + 9, y: wy - 10,
                width: 9, height: 2
            )
        } else {
            cr.rectangle(
                x: x - 15, y: wy - 13,
                width: 7, height: 7
            )
            cr.rectangle(
                x: x + 10, y: wy - 13,
                width: 7, height: 7
            )
        }
        cr.fill()

        // Sorriso
        cr.setSource(red: 0.42, green: 0.20, blue: 0.27)
        cr.rectangle(
            x: x - 4, y: wy + 5,
            width: 9, height: 3
        )
        cr.fill()

        // Chapeu pontudo
        cr.setSource(red: 0.34, green: 0.18, blue: 0.62)
        cr.moveTo(x - 58, wy - 34)
        cr.lineTo(x, wy - 112)
        cr.lineTo(x + 58, wy - 34)
        cr.fill()

        cr.rectangle(
            x: x - 61, y: wy - 38,
            width: 122, height: 14
        )
        cr.fill()

        // Estrela dourada
        cr.setSource(red: 0.98, green: 0.83, blue: 0.38)
        cr.rectangle(
            x: x - 5, y: wy - 70,
            width: 11, height: 11
        )
        cr.fill()
    }

    // MARK: - Frascos magicos

    private static func drawBottle(
        _ cr: Cairo.ContextRef,
        x: Double,
        y: Double,
        color: Bool
    ) {
        cr.setSource(red: 0.78, green: 0.77, blue: 0.88)
        cr.rectangle(
            x: x + 10, y: y,
            width: 14, height: 12
        )
        cr.fill()

        if color {
            cr.setSource(red: 0.65, green: 0.37, blue: 0.95)
        } else {
            cr.setSource(red: 0.28, green: 0.88, blue: 0.81)
        }

        cr.rectangle(
            x: x, y: y + 12,
            width: 34, height: 28
        )
        cr.fill()
    }
}
