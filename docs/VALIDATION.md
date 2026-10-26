# Validação gráfica pendente

1. Abra project.godot na Godot 4.7.2 e aguarde importação. Rode F5 e confirme que o robô anima Idle e fica visível à direita do menu.
2. Verifique que o menu cont?m apenas Jogar, Multiplayer local e Configura??es. Entre nos dois modos e alterne os seis modelos no seletor. Verifique proporções, mãos, pés, roupas e troca de seleção sem erros no Debugger.
3. Inicie partidas e confirme o sorteio de arenas. Ande contra os quatro limites; confira piso, sombras, visibilidade dos lutadores e ausência de atravessamento da câmera.
4. Corra com Shift: confira poeira e silhuetas da pose atual, sua remoção após parar e o custo no monitor de desempenho. Ajuste afterimage_interval no Inspector se necessário.
5. Próximo do alvo, pressione J três vezes durante as animações: confira dois socos e finalizador acelerado. Fora do alcance, o adversário não deve receber dano.
6. Pressione K: confirme carga na mão, lançamento, rastro e Reaction no alvo. Durante a conjuração, tente atacar: não deve interromper o disparo.
7. Segure L: verifique barreira e consumo de energia. Bloqueie pela frente e receba ataque pelas costas para comparar o dano. Escudo sem energia deve cair.
8. Confira IA, barras, derrota, vencedor, reinício, menu e pausa durante disparos. O personagem derrotado deve concluir a animação de queda.
9. Use teclado, mouse e gamepad no menu. Teste analógico e botões na luta.
10. Redimensione a janela e teste 1280×720. A interface foi composta para essa resolução virtual.

Captura opcional: `godot --path . --script scripts/tools/capture_preview.gd` abre uma janela, gera duas imagens em docs/ e encerra. Não foi executada nesta sessão porque a execução gráfica não foi autorizada.

11. No seletor solo, confirme P1 e CPU. No multiplayer, navegue simultaneamente pelos dois lados com WASD/J e setas/Num 1; confirme ambos. Repita com dois gamepads; A confirma e B desfaz.
12. Na luta local, confirme tela dividida, c?mera pr?xima para cada jogador, dire??o de movimento relativa ? c?mera e isolamento de teclas/bot?es. Pause por ambos os controles.
13. Confira o HUD espelhado no topo, retratos, barras de vida verde, energia azul, rastro de dano e resultado com identifica??o P1/P2.
14. Acerte socos, finalizadores, escudo e proj?teis: verifique fa?scas distintas e sua remo??o ap?s a emiss?o. Golpes no vazio n?o devem criar impacto no alvo.
