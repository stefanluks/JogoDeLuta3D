# Validação gráfica pendente

1. Abra project.godot na Godot 4.7.2 e aguarde importação. Rode F5 e confirme que o robô anima Idle e fica visível à direita do menu.
2. Alterne os seis modelos. Verifique proporções, mãos, pés, roupas e troca de seleção sem erros no Debugger.
3. Inicie cada arena e ande contra os quatro limites; confira piso, sombras, visibilidade dos lutadores e ausência de atravessamento da câmera.
4. Corra com Shift: confira poeira e silhuetas da pose atual, sua remoção após parar e o custo no monitor de desempenho. Ajuste afterimage_interval no Inspector se necessário.
5. Próximo do alvo, pressione J três vezes durante as animações: confira dois socos e finalizador acelerado. Fora do alcance, o adversário não deve receber dano.
6. Pressione K: confirme carga na mão, lançamento, rastro e Reaction no alvo. Durante a conjuração, tente atacar: não deve interromper o disparo.
7. Segure L: verifique barreira e consumo de energia. Bloqueie pela frente e receba ataque pelas costas para comparar o dano. Escudo sem energia deve cair.
8. Confira IA, barras, derrota, vencedor, reinício, menu e pausa durante disparos. O personagem derrotado deve concluir a animação de queda.
9. Use teclado, mouse e gamepad no menu. Teste analógico e botões na luta.
10. Redimensione a janela e teste 1280×720. A interface foi composta para essa resolução virtual.

Captura opcional: `godot --path . --script scripts/tools/capture_preview.gd` abre uma janela, gera duas imagens em docs/ e encerra. Não foi executada nesta sessão porque a execução gráfica não foi autorizada.
