extends SceneTree
var checks = 0
var failures = 0
func verify(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1
	checks += 1
func _initialize(): call_deferred("run")
func run():
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var menu = game.ui.get_child(0).find_children("*", "Button", true, false)
	verify(menu.size() == 3, "Only three main menu options")
	verify(menu[0].text == "JOGAR" and menu[1].text == "MULTIPLAYER LOCAL", "Menu routing")
	game._show_selection(false)
	var select = game.selector
	verify(select.tiles[0].size() == CharacterCatalog.entries().size(), "Full roster in solo grid")
	select._confirm(0)
	verify(not game.fighting and select.active_slot == 1, "CPU selection after player confirmation")
	select._confirm(1)
	verify(game.fighting and not game.enemy.human, "Solo starts against AI")
	verify(game.arena_index >= 0 and game.arena_index < 3, "Random arena is valid")
	var solo_camera = game.camera
	await physics_frame
	verify(solo_camera.global_position.distance_to(game.player.global_position) < 6, "Close third person camera")
	game._show_selection(true)
	select = game.selector
	verify(select.tiles[0].size() == select.roster.size() and select.tiles[1].size() == select.roster.size(), "Two independent roster grids")
	var p1 = select.cursors[0]
	var key = InputEventKey.new()
	key.physical_keycode = KEY_RIGHT
	key.pressed = true
	select._input(key)
	verify(select.cursors[0] == p1, "P2 navigation leaves P1 cursor untouched")
	verify(select.cursors[1] == posmod(select.roster.find(game.selected_enemy) + 1, select.roster.size()), "P2 arrow navigation")
	select._confirm(0)
	verify(not game.fighting, "Local waits for both players")
	select._confirm(1)
	verify(game.fighting and game.player.human and game.enemy.human, "Both local fighters human controlled")
	verify(game.enemy.input_prefix == "p2_", "Separate input map")
	verify(game.enemy.control_camera != game.player.control_camera, "Independent player cameras")
	verify(game.enemy.control_camera.get_viewport().world_3d == game.player.control_camera.get_viewport().world_3d, "Split viewports share physics world")
	await physics_frame
	var move = InputEventKey.new()
	move.physical_keycode = KEY_W
	move.pressed = true
	Input.parse_input_event(move)
	Input.flush_buffered_events()
	game.player._read_player()
	game.enemy._read_player()
	verify(game.player.move_intent.length() > 0.5 and game.enemy.move_intent.length() < 0.1, "Keyboard movement is isolated")
	move = move.duplicate()
	move.pressed = false
	Input.parse_input_event(move)
	var events = InputMap.action_get_events("p2_attack")
	var found_device = false
	for event in events:
		if event is InputEventJoypadButton and event.device == 1: found_device = true
	verify(found_device, "Gamepad 2 bindings")
	var sparks = CombatFX.hit_particles(game.stage, Vector3.UP, Vector3.BACK, true)
	verify(sparks.one_shot and sparks.amount == 32 and sparks.emitting, "Heavy hit particles")
	game._show_menu()
	verify(not game.fighting and not paused, "Return from local to menu")
	print("RESULT: ", checks, " UI / local multiplayer checks; failures=", failures)
	quit(1 if failures else 0)
