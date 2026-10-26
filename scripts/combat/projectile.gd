extends Area3D
@export var damage: float = 18.0
@export var speed: float = 15.0
@export var lifetime: float = 3.0
@export var color: Color = Color(0.15, 0.8, 1.0)
var shooter: CharacterBody3D
var direction = Vector3.FORWARD
var age = 0.0
var trail_clock = 0.0
func _ready() -> void:
	collision_layer = 4
	collision_mask = 3
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.22
	shape.shape = sphere
	add_child(shape)
	var visual = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.2
	mesh.height = 0.4
	visual.mesh = mesh
	visual.material_override = CombatFX.material(color)
	add_child(visual)
	var light = OmniLight3D.new()
	light.light_color = color
	light.omni_range = 3
	add_child(light)
	body_entered.connect(_impact)
func _physics_process(delta: float) -> void:
	age += delta
	if age > lifetime:
		queue_free()
		return
	var next = global_position + direction * speed * delta
	var query = PhysicsRayQueryParameters3D.create(global_position, next, collision_mask, [shooter.get_rid()])
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		_impact(hit.collider)
		return
	global_position = next
	trail_clock += delta
	if trail_clock > 0.045:
		trail_clock = 0
		CombatFX.burst(get_parent(), global_position, Color(color, 0.25), 0.18)
func _impact(body: Node) -> void:
	if body == shooter or is_queued_for_deletion(): return
	if body.has_method("receive_hit"): body.receive_hit(damage, direction, true)
	CombatFX.burst(get_parent(), global_position, color, 1.5)
	queue_free()
