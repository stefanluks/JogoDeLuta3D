extends SceneTree
var game
var frames = 0
func _initialize():
	call_deferred("start")
func start():
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
func _process(_delta):
	frames += 1
	if frames == 30:
		root.get_texture().get_image().save_png("res://docs/menu-preview.png")
	if frames == 31:
		game._start_fight()
	if frames == 80:
		game.player.run_intent = true
		CombatFX.afterimage(game.player.model, game.stage)
	if frames == 100:
		root.get_texture().get_image().save_png("res://docs/combat-preview.png")
	if frames == 110: quit()
