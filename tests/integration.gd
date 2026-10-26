extends SceneTree
var checks = 0
func verify(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		quit(1)
		assert(condition, message)
	checks += 1
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	verify(is_instance_valid(game.preview), "3D menu character")
	for path in CharacterCatalog.entries():
		var fighter = load("res://scenes/fighter.tscn").instantiate()
		fighter.character_path = path
		game.stage.add_child(fighter)
		verify(not fighter.animation.is_empty(), "AnimationTree installed on " + path)
		verify(fighter.animation.player.get_animation_list().size() == 11, "Shared states")
		for state in SharedAnimation.CLIPS:
			var clip = fighter.animation.player.get_animation(state)
			verify(clip.get_track_count() > 30, "Mapped tracks " + state)
			for track in clip.get_track_count():
				var bone = String(clip.track_get_path(track).get_subname(0))
				verify(fighter.animation.skeleton.find_bone(bone) >= 0, "No missing target bone")
		fighter.animation.tree.advance(0.2)
		fighter.queue_free()
		await process_frame
	for index in 3:
		game.arena_index = index
		game._start_fight()
		await physics_frame
		verify(game.player.opponent == game.enemy, "Opponent wiring")
		verify(game.stage.get_child(0).get_node("SpawnPlayer") != null, "Arena spawns")
	game.enemy.set_physics_process(false)
	game.player.set_physics_process(false)
	game.player.position = Vector3(0, 0.05, 0)
	game.player.rotation = Vector3.ZERO
	game.enemy.position = Vector3(0, 0.05, 1.2)
	await physics_frame
	game.player.attack()
	verify(game.player.state == "Punch1", "First punch")
	game.player.elapsed = game.player.duration * 0.4
	game.player.attack()
	verify(game.player.buffered, "Combo input buffer")
	game.player._melee()
	verify(game.enemy.health == 91, "Physical overlap applies damage")
	game.player.elapsed = game.player.duration
	game.player._physics_process(0.01)
	verify(game.player.state == "Punch2", "Second combo transition")
	game.player.elapsed = game.player.duration * 0.4
	game.player.attack()
	game.player.elapsed = game.player.duration
	game.player._physics_process(0.01)
	verify(game.player.state == "Finisher", "Third combo transition")
	game.enemy.set_state("Guard")
	game.enemy.rotation.y = PI
	var hp = game.enemy.health
	game.enemy.receive_hit(18, Vector3.BACK, true)
	verify(game.enemy.health == hp and game.enemy.state == "Guard", "Shield blocks frontal projectile")
	game.enemy.set_state("Idle")
	game.enemy.receive_hit(18, Vector3.BACK, true)
	verify(game.enemy.state == "Reaction", "Energy impact reaction")
	game.player.set_state("Idle")
	game.player.energy = 100
	game.player.cast()
	verify(game.player.energy == 75, "Energy cost")
	game.player.elapsed = game.player.duration * 0.6
	game.player._physics_process(0.01)
	verify(game.player.released, "Animation-timed projectile release")
	game.enemy.receive_hit(100, Vector3.BACK)
	verify(game.ended and game.enemy.state == "Defeat", "Round victory")
	game._start_fight()
	verify(game.player.health == 100 and not game.ended, "Restart")
	game._show_menu()
	verify(not game.fighting, "Return to menu")
	print("PASS: ", checks, " integration checks")
	quit()
