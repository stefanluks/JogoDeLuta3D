class_name CharacterCatalog
extends RefCounted
static func entries() -> Array[String]:
	var result: Array[String] = []
	for file in DirAccess.get_files_at("res://assets/characters"):
		if file.get_extension().to_lower() in ["fbx", "glb", "gltf", "tscn"]:
			result.append("res://assets/characters/" + file)
	result.sort()
	return result
static func bone_key(value: String) -> String:
	return value.get_slice("_", 1) if value.begins_with("mixamorig") else value.get_slice(":", value.get_slice_count(":") - 1)
