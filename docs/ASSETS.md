# Diagnóstico dos assets

Godot instalada: 4.7.2 stable. Projeto inicial: sem cena principal, scripts ou sistemas reutilizáveis. Preservados arquivos FBX e referências de importação. A Godot extraiu texturas embutidas para a pasta dos modelos durante a importação.

| Modelo | Ossos | Convenção |
|---|---:|---|
| X Bot | 65 | mixamorig_ |
| Y Bot | 65 | mixamorig_ |
| Ch06_nonPBR | 65 | mixamorig9_ |
| Remy | 67 | mixamorig_ |
| Vampire A Lusth | 99 | mixamorig_ |
| Whiteclown N Hallin | 67 | mixamorig_ |

Os modelos possuem Skeleton3D na raiz da cena importada. Remy tem aproximadamente 3,74 m no AABB original; os demais variam entre 1,80 e 2,11 m. A escala visual é normalizada para 2,20 m no lutador, independentemente da cápsula de colisão de 2,20 m (raio de 0,46 m).

| Estado | Arquivo FBX | Clipe | Duração original |
|---|---|---|---:|
| Idle | Idle | mixamo_com | 3,633 s |
| Walk | Walking | mixamo_com | 1,033 s |
| Run | Running (1) | mixamo_com | 0,633 s |
| Punch1 / Finisher | Punching | mixamo_com | 1,033 s |
| Punch2 | Punching (1) | mixamo_com | 1,000 s |
| Spell | Standing 1H Magic Attack 01 | mixamo_com | 2,300 s |
| Guard | Standing Block Idle | mixamo_com | 2,767 s |
| Hit | Head Hit | mixamo_com | 1,433 s |
| Reaction | Reaction | mixamo_com | 1,833 s |
| Defeat | Standing React Death Right | mixamo_com | 3,500 s |

Crouch To Stand foi preservado, sem uso no combate terrestre atual. Take 001 é um take adicional e não deve substituir automaticamente mixamo_com.
