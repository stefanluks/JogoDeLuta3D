extends SceneTree
var checks = 0
var failures = 0
func verify(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize(): call_deferred("run")
func run():
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var title = game.ui.get_child(0).find_child("MenuTitle", true, false)
	verify(title.get_theme_font("font") is SystemFont, "Custom display typeface")
	var labels = game.ui.get_child(0).find_children("*", "Label", true, false)
	verify(labels.size() == 1, "Only title remains on menu")
	var buttons = game.ui.get_child(0).find_children("*", "Button", true, false)
	verify(buttons.size() == 3 and buttons[2].text == "CONFIGURAÇÕES", "Correct menu options and accents")
	verify(buttons[0].global_position.y > 400, "Buttons moved lower")
	verify(game.menu_camera.fov == 34 and game.menu_camera.position.z <= 5, "Close menu framing")
	var previous = game.preview.character_path
	for i in 6:
		game._show_menu()
		verify(game.preview.character_path != previous, "New random preview on each menu entry")
		previous = game.preview.character_path
	for path in CharacterCatalog.entries():
		var fighter = load("res://scenes/fighter.tscn").instantiate()
		fighter.character_path = path
		game.stage.add_child(fighter)
		fighter.frozen = true
		verify(is_equal_approx(fighter.body_collider.shape.height, 2.2) and fighter.body_collider.shape.radius > 0.4, "Larger collider: " + path)
		verify(is_zero_approx(fighter.body_collider.position.y - fighter.body_collider.shape.height / 2), "Collider bottom at ground")
		verify(fighter.support_bones.size() == 4, "Foot support mapping: " + path)
		for frame in 20:
			fighter._physics_process(0.1)
			var skeleton: Skeleton3D = fighter.animation.skeleton
			var lowest = INF
			for bone in fighter.support_bones:
				lowest = minf(lowest, (skeleton.global_transform * skeleton.get_bone_global_pose(bone).origin).y)
			var sole = lowest + fighter.sole_clearance * fighter.model.scale.y
			verify(absf(sole) < 0.002, "Animated feet grounded: " + path)
		fighter.queue_free()
		await process_frame
	print("RESULT: ", checks, " menu and grounding checks; failures=", failures)
	quit(1 if failures else 0)
