class_name ArenaBuilder
extends Node3D
const NAMES = ["Vale dos Guerreiros", "Ruínas Espirituais", "Ilha dos Titãs"]
static func solid(parent: Node3D, point: Vector3, size: Vector3, color: Color, collision: bool = true) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.roughness = 0.9
	mesh.material_override = mat
	parent.add_child(mesh)
	mesh.position = point
	if collision:
		var body = StaticBody3D.new()
		mesh.add_child(body)
		var shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
	return mesh
func build(index: int) -> void:
	var palette = [Color("9e8055"), Color("58677e"), Color("c4b684")]
	solid(self, Vector3(0, -0.4, 0), Vector3(38, 0.8, 38), palette[index])
	for side in [-1, 1]:
		solid(self, Vector3(side * 18.5, 1.5, 0), Vector3(1, 3, 38), palette[index].darkened(0.25))
		solid(self, Vector3(0, 1.5, side * 18.5), Vector3(38, 3, 1), palette[index].darkened(0.25))
	for x in range(-16, 17, 4):
		solid(self, Vector3(x, 0.015, 0), Vector3(0.04, 0.02, 36), palette[index].lightened(0.12), false)
		solid(self, Vector3(0, 0.015, x), Vector3(36, 0.02, 0.04), palette[index].lightened(0.12), false)
	var random = RandomNumberGenerator.new()
	random.seed = 701 + index
	for i in 32:
		var angle = TAU * i / 32
		var radius = random.randf_range(23, 34)
		var point = Vector3(sin(angle) * radius, 0, cos(angle) * radius)
		if index == 1:
			var pillar = solid(self, point + Vector3.UP * 4, Vector3(1.8, 8, 1.8), Color("b2bace"), false)
			solid(pillar, Vector3(0, 4, 0), Vector3(3, 0.5, 3), Color("29334f"), false)
		else:
			var height = random.randf_range(4, 13)
			var rock = solid(self, point + Vector3.UP * height / 2, Vector3(4, height, 5), palette[index].darkened(0.3), false)
			rock.rotation = Vector3(0.1, angle, 0.2)
			if i % 2 == 0:
				solid(self, point + Vector3.UP * 4, Vector3(0.6, 8, 0.6), Color("614c39"), false)
				var crown = solid(self, point + Vector3.UP * 8, Vector3(5, 2, 5), Color("3d775e"), false)
				crown.rotation.y = angle
	if index == 2:
		var sea = solid(self, Vector3(0, -1.2, 0), Vector3(250, 0.1, 250), Color("207d9a"), false)
		sea.material_override.roughness = 0.2
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, -35, 0)
	sun.light_color = Color("ffd3a0") if index == 0 else Color("bfd9ff")
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	add_child(sun)
	var world = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = [Color("a8a0ae"), Color("3e4f70"), Color("80c7e5")][index]
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("becde5")
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	for side in [-1, 1]:
		var spawn = Marker3D.new()
		spawn.name = "SpawnPlayer" if side == -1 else "SpawnOpponent"
		spawn.position = Vector3(side * 4, 0.05, 0)
		add_child(spawn)
