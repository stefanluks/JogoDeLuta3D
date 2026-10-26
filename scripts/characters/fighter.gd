class_name Fighter
extends CharacterBody3D
signal defeated(fighter)
signal heavy_hit
@export_file("*.fbx", "*.glb", "*.tscn") var character_path = "res://assets/characters/X Bot.fbx"
@export var human = false
@export var input_prefix = ""
var control_camera: Camera3D
@export var display_name = "Fighter"
@export var walk_speed = 3.2
@export var run_speed = 7.5
@export var acceleration = 24.0
@export var aggression = 0.65
@export var reaction_time = 0.4
@export var afterimages_enabled = true
@export_range(0.08, 0.5) var afterimage_interval = 0.12
var health = 100.0
var energy = 100.0
var opponent: Fighter
var model: Node3D
var animation: Dictionary
var state = "Idle"
var elapsed = 0.0
var duration = 0.0
var rate = 1.0
var combo = 0
var buffered = false
var landed = false
var released = false
var guard_intent = false
var move_intent = Vector3.ZERO
var run_intent = false
var frozen = false
var lock_on = true
var ai_clock = 0.0
var ai_guard = 0.0
var fx_clock = 0.0
var dust: GPUParticles3D
var shield: MeshInstance3D
var charge: MeshInstance3D
var hand: BoneAttachment3D
const ACTIONS = ["Punch1", "Punch2", "Finisher", "Spell", "Hit", "Reaction", "Defeat"]
func _ready() -> void:
	collision_layer = 2
	collision_mask = 3
	var collider = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.36
	capsule.height = 1.8
	collider.shape = capsule
	collider.position.y = 0.9
	add_child(collider)
	model = load(character_path).instantiate()
	model.name = "Model"
	add_child(model)
	var height = 0.0
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		height = maxf(height, mesh.get_aabb().end.y)
		for surface in mesh.mesh.get_surface_count():
			var original = mesh.get_active_material(surface)
			if original is StandardMaterial3D:
				var toon = ShaderMaterial.new()
				toon.shader = load("res://shaders/character_toon.gdshader")
				toon.set_shader_parameter("base_color", original.albedo_color)
				if original.albedo_texture:
					toon.set_shader_parameter("has_texture", true)
					toon.set_shader_parameter("albedo_texture", original.albedo_texture)
				mesh.set_surface_override_material(surface, toon)
	if height > 0: model.scale = Vector3.ONE * 1.85 / height
	animation = SharedAnimation.install(model)
	if animation.is_empty():
		set_physics_process(false)
		return
	animation.tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	hand = BoneAttachment3D.new()
	for bone in animation.skeleton.get_bone_count():
		if CharacterCatalog.bone_key(animation.skeleton.get_bone_name(bone)) == "RightHand":
			hand.bone_name = animation.skeleton.get_bone_name(bone)
			break
	animation.skeleton.add_child(hand)
	charge = MeshInstance3D.new()
	var orb = SphereMesh.new()
	orb.radius = 0.16
	orb.height = 0.32
	charge.mesh = orb
	charge.material_override = CombatFX.material(Color(0.2, 0.85, 1, 0.8))
	hand.add_child(charge)
	charge.visible = false
	shield = MeshInstance3D.new()
	var barrier = SphereMesh.new()
	barrier.radius = 0.9
	barrier.height = 1.8
	shield.mesh = barrier
	shield.material_override = CombatFX.material(Color(0.15, 0.7, 1, 0.2))
	add_child(shield)
	shield.position = Vector3(0, 1, 0.55)
	shield.scale.z = 0.3
	shield.visible = false
	dust = CombatFX.dust(self)
func set_state(next: String, speed: float = 1.0) -> void:
	if state == next: return
	state = next
	elapsed = 0
	rate = speed
	duration = animation.player.get_animation(next).length / rate
	animation.playback.travel(next)
	landed = false
	released = false
func attack() -> void:
	if frozen or health <= 0: return
	if state in ["Punch1", "Punch2"]:
		if elapsed / duration >= 0.15: buffered = true
	elif state not in ACTIONS and state != "Guard":
		combo = 1
		buffered = false
		set_state("Punch1", 1.5)
func cast() -> void:
	if frozen or health <= 0 or state in ACTIONS or state == "Guard" or energy < 25: return
	energy -= 25
	set_state("Spell", 1.45)
func receive_hit(amount: float, direction: Vector3, special: bool = false) -> void:
	if frozen or health <= 0: return
	var frontal = global_basis.z.dot(-direction) > 0.15
	if state == "Guard" and frontal and energy >= amount * 0.7:
		energy -= amount * 0.7
		CombatFX.hit_particles(get_parent(), global_position + Vector3.UP, -direction, false, Color(0.2, 0.8, 1))
		CombatFX.burst(get_parent(), global_position + Vector3.UP, Color(0.25, 0.8, 1), 0.8)
		return
	health = maxf(0, health - amount)
	buffered = false
	combo = 0
	velocity += direction * (5.0 if special else 2.5)
	if health <= 0:
		set_state("Defeat")
		defeated.emit(self)
	else:
		set_state("Reaction" if special else "Hit", 1.8)
func _physics_process(delta: float) -> void:
	animation.tree.advance(delta * rate)
	if frozen: return
	elapsed += delta
	if health <= 0:
		velocity = velocity.move_toward(Vector3.ZERO, acceleration * delta)
		move_and_slide()
		return
	if human: _read_player()
	else: _read_ai(delta)
	if is_instance_valid(opponent) and opponent.health > 0 and lock_on:
		var difference = opponent.global_position - global_position
		if difference.length_squared() > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(difference.x, difference.z), 1.0 - exp(-14 * delta))
	if state in ACTIONS:
		var progress = elapsed / maxf(duration, 0.01)
		if state in ["Punch1", "Punch2", "Finisher"] and progress >= 0.32 and progress <= 0.58 and not landed:
			_melee()
		if state == "Spell":
			charge.visible = progress > 0.1 and progress < 0.55
			charge.scale = Vector3.ONE * clampf(progress * 2, 0.1, 1.2)
			if progress >= 0.55 and not released:
				released = true
				var projectile = preload("res://scenes/projectile.tscn").instantiate()
				projectile.shooter = self
				projectile.direction = (opponent.global_position + Vector3.UP - hand.global_position).normalized() if is_instance_valid(opponent) else global_basis.z
				get_parent().add_child(projectile)
				projectile.global_position = hand.global_position + projectile.direction * 0.45
		if progress >= 1 and state != "Defeat":
			if buffered and combo < 3 and combo > 0:
				combo += 1
				buffered = false
				set_state("Punch2" if combo == 2 else "Finisher", 1.6 if combo == 2 else 2.0)
			else:
				combo = 0
				set_state("Idle")
	else:
		if guard_intent and energy > 3:
			set_state("Guard")
			energy = maxf(0, energy - delta * 18)
		else:
			set_state("Run" if run_intent and move_intent.length() > 0.1 else ("Walk" if move_intent.length() > 0.1 else "Idle"))
	var target_velocity = move_intent * (run_speed if run_intent else walk_speed) if state in ["Idle", "Walk", "Run"] else Vector3.ZERO
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	velocity.y = -1 if is_on_floor() else velocity.y - 20 * delta
	move_and_slide()
	position.x = clampf(position.x, -17.3, 17.3)
	position.z = clampf(position.z, -17.3, 17.3)
	if not lock_on and move_intent.length() > 0.1: rotation.y = lerp_angle(rotation.y, atan2(move_intent.x, move_intent.z), delta * 12)
	shield.visible = state == "Guard"
	if state != "Spell": charge.visible = false
	if state not in ["Spell", "Guard"]: energy = minf(100, energy + delta * 9)
	dust.emitting = state == "Run"
	fx_clock += delta
	if afterimages_enabled and fx_clock >= afterimage_interval and (state == "Run" or state == "Finisher"):
		fx_clock = 0
		if DisplayServer.get_name() != "headless": CombatFX.afterimage(model, get_parent())
func _melee() -> void:
	if not is_instance_valid(opponent) or opponent.health <= 0: return
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.7
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, global_position + Vector3.UP + global_basis.z * 0.85)
	query.collision_mask = 2
	query.exclude = [get_rid()]
	for hit in get_world_3d().direct_space_state.intersect_shape(query):
		if hit.collider == opponent:
			landed = true
			CombatFX.hit_particles(get_parent(), opponent.global_position + Vector3.UP, global_basis.z, combo == 3)
			opponent.receive_hit(16 if combo == 3 else 9, global_basis.z)
			CombatFX.burst(get_parent(), opponent.global_position + Vector3.UP, Color(1, 0.65, 0.15), 1.4 if combo == 3 else 0.7)
			if combo == 3: heavy_hit.emit()
func _read_player() -> void:
	var input = Input.get_vector(input_prefix + "move_left", input_prefix + "move_right", input_prefix + "move_forward", input_prefix + "move_back")
	var camera = control_camera if is_instance_valid(control_camera) else get_viewport().get_camera_3d()
	if not is_instance_valid(camera): return
	var forward = -camera.global_basis.z
	forward.y = 0
	forward = forward.normalized()
	move_intent = (camera.global_basis.x * input.x - forward * input.y).normalized()
	run_intent = Input.is_action_pressed(input_prefix + "run")
	guard_intent = Input.is_action_pressed(input_prefix + "guard")
	if Input.is_action_just_pressed(input_prefix + "attack"): attack()
	if Input.is_action_just_pressed(input_prefix + "special"): cast()
	if Input.is_action_just_pressed(input_prefix + "lock_on"): lock_on = not lock_on
func _read_ai(delta: float) -> void:
	move_intent = Vector3.ZERO
	if not is_instance_valid(opponent) or opponent.health <= 0: return
	ai_clock -= delta
	ai_guard -= delta
	guard_intent = ai_guard > 0
	var difference = opponent.global_position - global_position
	var distance = difference.length()
	if distance > 1.55 and not guard_intent: move_intent = difference.normalized()
	run_intent = distance > 5
	if ai_clock > 0: return
	ai_clock = reaction_time + randf_range(0.15, 0.65)
	if opponent.state == "Spell" and randf() > 0.35:
		ai_guard = 1.1
	elif distance < 2 and randf() < aggression:
		attack()
	elif distance > 3 and randf() < 0.45:
		cast()
