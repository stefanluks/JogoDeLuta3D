extends SubViewportContainer
var fighter: Fighter
var viewport: SubViewport
func setup(path: String, live: bool = true, close_up: bool = false) -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport = SubViewport.new()
	viewport.size = Vector2i(256, 320)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if live else SubViewport.UPDATE_ONCE
	add_child(viewport)
	var world = Node3D.new()
	viewport.add_child(world)
	fighter = preload("res://scenes/fighter.tscn").instantiate()
	fighter.character_path = path
	world.add_child(fighter)
	fighter.frozen = true
	fighter.rotation.y = -0.22
	fighter.animation.tree.advance(0.1)
	if not live: fighter.set_physics_process(false)
	var camera = Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(0, 1.5, 1.8) if close_up else Vector3(0, 1.15, 3.2)
	camera.look_at(Vector3(0, 1.45, 0) if close_up else Vector3(0, 0.95, 0))
	camera.fov = 34
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25, -25, 0)
	light.light_energy = 2.0
	world.add_child(light)
	var fill = OmniLight3D.new()
	fill.position = Vector3(-2, 2, 2)
	fill.light_color = Color(0.4, 0.7, 1)
	fill.light_energy = 1.5
	world.add_child(fill)
