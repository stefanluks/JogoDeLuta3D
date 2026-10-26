# Altera??es por funcionalidade

A branch permanece `feat/arena-combat-shared-characters`. O diret?rio de trabalho estava limpo no in?cio desta etapa. A tentativa de gravar o primeiro commit foi bloqueada por restri??o de escrita na pasta `.git`; a solicita??o de autoriza??o foi recusada. Nenhum commit desta etapa foi criado.

## Grupos para commits

1. `feat(camera): bring combat view closer over the shoulder` ? `scripts/camera/combat_camera.gd`: dist?ncia, altura, ombro e FOV edit?veis; obstru??o preservada.
2. `feat(vfx): add directional sparks to combat impacts` ? `scripts/effects/combat_fx.gd`, `scripts/combat/projectile.gd` e trechos de `scripts/characters/fighter.gd` relativos a `hit_particles`: emiss?es ?nicas, finalizador refor?ado e cores de bloqueio/energia.
3. `feat(hud): add mirrored arcade health and energy display` ? `scripts/ui/fight_hud.gd`, `scripts/ui/character_portrait.gd` e substitui??o do HUD em `scripts/ui/game.gd`: molduras, retratos, barras, rastro de dano e centro de rodada.
4. `feat(selection): add classic roster flow and random arenas` ? `scripts/ui/character_select.gd` e fluxo do menu/sele??o/sorteio em `scripts/ui/game.gd`: menu de tr?s op??es, previews animados, grade solo e dupla local.
5. `feat(multiplayer): add independent local input and split screen` ? trechos restantes de `scripts/ui/game.gd` e `scripts/characters/fighter.gd`: InputMap de P2, teclado/gamepads separados, c?meras pr?prias e resultado P1/P2.
6. `test: cover selection local multiplayer and document controls` ? `tests/ui_multiplayer.gd`, `tests/integration.gd`, README e documenta??o.

Arquivos compartilhados entre funcionalidades precisam de staging por trecho (`git add -p`) para preservar essa divis?o.

## Verifica??o executada

- Integra??o: 3.538 verifica??es aprovadas.
- Interface e multiplayer local: 19 verifica??es aprovadas, incluindo confirma??o dos dois lados, isolamento de movimento, compartilhamento do mundo f?sico entre viewports e bindings do segundo gamepad.
- Luta aut?noma: rodada encerrada normalmente com derrota de um lutador.
- Verifica??o visual e gamepads f?sicos: pendentes. A autoriza??o de execu??o gr?fica j? havia sido recusada; n?o foi contornada.
- O headless emite aviso sobre o reposit?rio de certificados do Windows, sem impedir os testes.
