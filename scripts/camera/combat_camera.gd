class_name CombatCamera
extends Camera3D
@export var follow_speed = 8.0
@export var follow_distance = 3.4
@export var shoulder_offset = 0.65
@export var camera_height = 1.9
var player: Fighter
var opponent: Fighter
var shake = 0.0
var initialized = false
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(opponent): return
	var difference = opponent.global_position - player.global_position
	var direction = difference.normalized()
	if direction.length_squared() < 0.1: direction = Vector3.FORWARD
	var distance = clampf(difference.length(), 2, 22)
	var target = player.global_position + Vector3.UP * 1.25 + direction * minf(distance * 0.22, 2.5)
	var desired = player.global_position - direction * (follow_distance + minf(distance * 0.045, 1.0)) + Vector3.UP * camera_height + direction.cross(Vector3.UP) * shoulder_offset
	var query = PhysicsRayQueryParameters3D.create(target, desired, 1)
	var obstruction = get_world_3d().direct_space_state.intersect_ray(query)
	if not obstruction.is_empty(): desired = obstruction.position + obstruction.normal * 0.4
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta)) if initialized else desired
	initialized = true
	shake = move_toward(shake, 0, delta * 1.5)
	look_at(target + Vector3(randf_range(-shake, shake), randf_range(-shake, shake), 0))
	fov = lerpf(fov, 70.0 if player.state != "Spell" else 64.0, delta * 5)
