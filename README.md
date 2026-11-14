# 🧙 Little Wizard — Potion Lab

Jogo 2D de alquimia em Swift, GTK4 e Cairo para Linux. Primeira versão jogável: selecione dois ingredientes, prepare poções, descubra três receitas e acumule pontos.

## Receitas
- Flor lunar + Cristal azul = Poção da Lua
- Cogumelo + Erva mística = Poção de Cura
- Cristal azul + Erva mística = Poção de Mana

Cada descoberta inédita rende 50 pontos e 10 moedas. Combinações diferentes produzem uma mistura misteriosa.

## Como rodar no Ubuntu
Este pacote reutiliza as dependências do seu projeto RiggieSee já funcional:

```bash
bash setup.sh
swift build -j 1
swift run
```

O arquivo `setup.sh` copia apenas a configuração SwiftPM do RiggieSee, renomeando o target para LittleWizard. Ele não modifica o projeto original.

## Próximas versões
Animação do caldeirão, livro de receitas, clientes, inventário e sprites pixel art.
