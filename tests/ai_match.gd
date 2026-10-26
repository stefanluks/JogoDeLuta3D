extends SceneTree
func _initialize():
	call_deferred("run")
func run():
	seed(42)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_fight()
	game.player.human = false
	for frame in 3600:
		await physics_frame
		if game.ended:
			print("PASS: autonomous round ended; health=", game.player.health, "/", game.enemy.health, " frame=", frame)
			quit()
			return
	push_error("Autonomous round did not finish within 60 simulated seconds")
	quit(1)
