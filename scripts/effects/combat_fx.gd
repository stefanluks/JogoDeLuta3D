class_name CombatFX
extends RefCounted
static func material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = Color(color, 1.0)
	mat.emission_energy_multiplier = 2.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat
static func burst(parent: Node3D, point: Vector3, color: Color, size: float = 1.0) -> void:
	var ring = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.15
	mesh.height = 0.3
	ring.mesh = mesh
	ring.material_override = material(color)
	parent.add_child(ring)
	ring.global_position = point
	var tween = ring.create_tween().set_parallel()
	tween.tween_property(ring, "scale", Vector3.ONE * size * 5.0, 0.25)
	tween.tween_property(ring, "transparency", 1.0, 0.25)
	tween.chain().tween_callback(ring.queue_free)
static func dust(parent: Node3D) -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 0.45
	particles.local_coords = false
	var process = ParticleProcessMaterial.new()
	process.direction = Vector3.UP
	process.spread = 70
	process.initial_velocity_min = 0.4
	process.initial_velocity_max = 1.4
	process.gravity = Vector3(0, -1, 0)
	process.scale_min = 0.025
	process.scale_max = 0.08
	process.color = Color(0.7, 0.65, 0.5, 0.4)
	particles.process_material = process
	var mesh = SphereMesh.new()
	mesh.material = material(Color(0.7, 0.65, 0.5, 0.25))
	particles.draw_pass_1 = mesh
	particles.emitting = false
	parent.add_child(particles)
	return particles
static func afterimage(model: Node3D, parent: Node3D) -> void:
	var ghost = Node3D.new()
	parent.add_child(ghost)
	for original in model.find_children("*", "MeshInstance3D", true, false):
		var copy = MeshInstance3D.new()
		copy.mesh = original.bake_mesh_from_current_skeleton_pose() if original.skin else original.mesh
		copy.material_override = material(Color(0.15, 0.8, 1.0, 0.16))
		ghost.add_child(copy)
		copy.global_transform = original.global_transform
		copy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var tween = ghost.create_tween()
	tween.tween_method(func(alpha):
		for child in ghost.get_children(): child.transparency = alpha, 0.0, 1.0, 0.22)
	tween.tween_callback(ghost.queue_free)
