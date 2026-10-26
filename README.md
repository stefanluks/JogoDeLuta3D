# The Fight — Pulse Arena

Protótipo educacional de combate terrestre 3D em Godot **4.7.2**, usando GDScript e os modelos fornecidos. Branch de desenvolvimento: `feat/arena-combat-shared-characters`.

## Executar

1. Abra `project.godot` na Godot 4.7.2 e aguarde a importação dos FBX e das texturas embutidas.
2. Pressione **F6** em `scenes/main.tscn`, ou **F5** para iniciar o projeto.
3. Escolha arena, personagem e adversário. Selecione **Jogar**.

O renderizador Compatibility prioriza compatibilidade com máquinas convencionais. Não há downloads ou addons necessários.

## Controles

| Ação | Teclado | Gamepad |
|---|---|---|
| Mover | WASD | Analógico esquerdo |
| Correr | Shift | RB |
| Soco / combo | J | X / botão oeste |
| Energia | K | Y / botão norte |
| Defender | Segurar L | LB |
| Alternar orientação lock-on | Tab | Clique analógico direito |
| Pausar | Esc | Start |

Menus aceitam mouse, teclado e navegação padrão da Godot por gamepad. As ações ficam no InputMap; não há salto ou voo. A câmera mantém o enquadramento do adversário mesmo com orientação livre.

## Implementado

- Menu com personagem 3D animado; seleção independente dos dois lutadores e de três arenas.
- Catálogo automático de personagens, biblioteca compartilhada de 11 estados e `AnimationTree` com transições de 100 ms.
- Movimento com aceleração, colisão, corrida, orientação e câmera suave com teste de obstrução.
- Combo Soco 1 → Soco 2 → Soco 1 acelerado; entrada antecipada após 15% da animação, janela de acerto entre 32% e 58%, um acerto por golpe, dano e recuo.
- Projétil reutilizável com lançamento a 55% de Spell, emissão, luz, rastro, impacto e detecção contínua por raio para evitar atravessar alvos.
- Barreira translúcida frontal: consumo contínuo e por bloqueio; ataques pelas costas e energia insuficiente rompem a proteção.
- Vida, energia, regeneração, reação física/especial, derrota, resultado, reinício e pausa.
- IA com aproximação, corrida, combos, disparos, defesa e tempo de reação ajustável.
- Poeira GPU e afterimages da pose atual, limitados por intervalo e removidos após 220 ms. Não duplicam jogadores de animação ou esqueletos.
- Material toon com textura original e parâmetros editáveis; sem dependências de shaders de terceiros.
- Vale dos Guerreiros, Ruínas Espirituais e Ilha dos Titãs: cenários procedurais estilizados, piso, limites físicos, iluminação e pontos de spawn.

## Adicionar personagens

Coloque uma cena `.fbx`, `.glb`, `.gltf` ou `.tscn` em **`assets/characters/`** e aguarde sua importação. Ela aparecerá nos seletores ao abrir o menu. Não coloque animações nessa pasta.

Por enquanto, todos utilizam os mesmos arquivos de `assets/animations/`. Os seis modelos fornecidos foram verificados com os onze estados compartilhados. O adaptador reconhece ossos Mixamo por nome sem prefixo, inclusive `mixamorig9_`, remapeia caminhos, adapta rotações à pose de repouso e mantém as posições de repouso dos ossos para preservar proporções e evitar root motion. A altura visual é normalizada para 1,85 m.

**Compatibilidade:** o personagem precisa de `Skeleton3D`, skin e ossos humanoides equivalentes aos do Mixamo. Soltar qualquer esqueleto arbitrário na pasta não garante retargeting correto. Modelos de outra convenção precisam de mapeamento adicional; ossos sem correspondência permanecem na pose de repouso. A animação usa rotações e mantém as translações dos ossos em repouso, portanto o balanço vertical original do quadril fica suprimido. Confira pés, mãos e roupa no editor ao adicionar novos modelos.

Selecione a cena `scenes/fighter.tscn` para ajustar velocidades, aceleração, agressividade, tempo de reação, modelo e frequência dos afterimages pelo Inspector. `SharedAnimation.CLIPS` centraliza os mapeamentos. O clipe real em cada arquivo é **`mixamo_com`**; o take embutido `Take 001` não corresponde necessariamente à ação do arquivo e não é usado.

## Estrutura

```text
assets/characters/       Modelos originais e texturas extraídas pela Godot
assets/animations/       FBX originais compartilhados
scenes/                 Entrada principal, lutador e projétil reutilizáveis
scripts/characters/     Catálogo, adaptação de animações e lutador
scripts/combat/         Projétil e colisão contínua
scripts/camera/         Câmera de combate
scripts/effects/        Poeira, impacto e silhuetas temporárias
scripts/arenas/         Construção procedural das três arenas
scripts/ui/             Fluxo de menus, partida e HUD
scripts/tools/          Inspeção de assets e captura opcional de previews
shaders/                Shader toon original
tests/                 Teste de integração headless
docs/                  Diagnóstico e roteiro de validação
```

As cenas constroem seus componentes em `_ready()`: executar a cena principal conecta modelos, animações, colisões, sinais e interface. Os FBX originais permanecem nos caminhos fornecidos; os `.import` registram as configurações de importação. Não versione `.godot/`.

## Verificação

```powershell
godot --headless --path . --import --editor --quit
godot --headless --path . --scripttests/integration.gd
godot --headless --path . --quit-after 120
```

O teste de integração executou **3.535 verificações**: seis esqueletos, estados/trilhas, três arenas, colisão de soco, buffer e três golpes, escudo frontal, reação especial, consumo e lançamento de energia, vitória, reinício e menu. Uma luta autônoma entre duas IAs também terminou com derrota e resultado em menos de 15 segundos simulados no teste desta etapa. Essas verificações não substituem a avaliação visual ou de desempenho.

A execução gráfica para capturar e verificar materiais/afterimages não foi autorizada nesta sessão. Portanto **a renderização, o enquadramento e o acabamento visual ainda exigem validação manual**, seguindo `docs/VALIDATION.md`. A Godot headless apresentou um aviso de acesso ao repositório de certificados do Windows; o teste concluiu sem erro de script. Na importação dentro do sandbox também houve restrição ao salvamento das preferências globais da Godot.

## Limitações e próximos passos

- Arenas são uma primeira versão procedural com geometria nativa; ainda precisam de direção de arte, vegetação mais elaborada, água animada, névoa e partículas ambientais.
- Escudo usa uma esfera achatada transparente; bordas dedicadas, ondulações e partículas de bloqueio ainda precisam ser refinadas.
- Toon inicial preserva texturas, mas não inclui contorno invertido ou bloom. No Compatibility, a emissão não produz bloom de pós-processamento.
- Afterimages usam bake de malha por amostra e podem custar caro em modelos densos. Ajuste o intervalo ou desative `afterimages_enabled` em máquinas lentas; falta medir desempenho com GPU real.
- Sem áudio fornecido: o volume geral está conectado ao barramento Master, mas não há música nem efeitos sonoros.
- Câmera automática; sem controle manual, remapeamento por interface ou persistência de configurações.
- Multiplayer local não implementado. O lutador aceita intenções separadas da leitura de controles, permitindo extrair novos controladores futuramente.
- Tempos de acerto/lançamento são normalizados na duração dos clipes, ainda precisam de ajuste visual fino por animação. Falta suporte a eventos autorais por golpe.
- Novos modelos precisam ser humanoides compatíveis. Retargeting genérico e ajustes individuais de importação ficam para uma próxima etapa.

## Origem dos recursos

Modelos e animações foram fornecidos na pasta do projeto pelo usuário. Os nomes dos ossos e dos clipes indicam convenção Mixamo, mas a origem exata e as licenças não foram disponibilizadas. Não se presume autorização de redistribuição: registre autor, fonte e condições antes de publicar. Código, shader e ambientes procedurais foram implementados neste projeto; nenhum conteúdo de Dragon Ball foi adicionado.

Referências técnicas oficiais: [AnimationTree](https://docs.godotengine.org/en/4.7/tutorials/animation/animation_tree.html) e [retargeting de esqueletos](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html).

## Sobre o projeto

> Este jogo é um projeto de treinamento e estudo de desenvolvimento de jogos 3D utilizando a Godot Engine. Seu objetivo é explorar sistemas de combate, animações, efeitos visuais, inteligência artificial e construção de ambientes interativos.
>
> O projeto encontra-se em desenvolvimento e futuramente receberá personagens, cenários, habilidades e elementos visuais totalmente originais, construindo uma identidade própria e independente das obras que serviram de inspiração para o estudo.

## Sele??o e multiplayer local

No modo solo, WASD ou setas navegam pela grade, J/Enter confirmam o personagem e depois o advers?rio CPU. Tab alterna o lado em edi??o. No multiplayer, as duas grades representam sele??es independentes: P1 usa WASD + J, P2 usa setas + Num 1. Clique num retrato para selecionar; o bot?o central confirma o lado ativo. Nos gamepads 0 e 1, anal?gico move o cursor, A confirma e B desfaz. Esc volta ao menu. Ap?s ambas as confirma??es, a arena ? sorteada.

Durante a luta, P1 mant?m WASD / Shift / J / K / L. P2 usa setas / Num 0 (corrida) / Num 1 (soco) / Num 2 (energia) / Num 3 (escudo) / Num 5 (lock-on). Gamepad 0 controla P1 e gamepad 1 controla P2. Cada jogador se move em rela??o ? pr?pria c?mera. Start de qualquer controle pausa. O HUD ? compartilhado sobre as duas metades.

As refer?ncias visuais orientaram a composi??o das barras, os grandes previews laterais e as grades do seletor. Foram utilizados apenas os personagens do projeto, com molduras e cores pr?prias.

### Organiza??o das altera??es desta etapa

Os commits solicitados n?o puderam ser gravados porque a autoriza??o de escrita na pasta `.git` foi recusada. As altera??es est?o no diret?rio de trabalho da branch existente. Veja `docs/CHANGES.md` para os grupos por funcionalidade e valida??es.
