extends SceneTree
func _initialize():
	for dir in ["characters", "animations"]:
		for file in DirAccess.get_files_at("res://assets/" + dir):
			if not file.ends_with(".fbx"): continue
			var scene = load("res://assets/" + dir + "/" + file).instantiate()
			print("ASSET ", file)
			for node in scene.find_children("*", "Skeleton3D", true, false):
				print("SKELETON ", scene.get_path_to(node), " bones=", node.get_bone_count(), " first=", node.get_bone_name(0), " rest=", node.get_bone_rest(0))
			for node in scene.find_children("*", "AnimationPlayer", true, false):
				for anim in node.get_animation_list():
					var a = node.get_animation(anim)
					print("ANIM ", anim, " length=", a.length, " tracks=", a.get_track_count(), " path=", a.track_get_path(0) if a.get_track_count() else "")
			for node in scene.find_children("*", "MeshInstance3D", true, false):
				print("MESH ", node.name, " aabb=", node.get_aabb())
			scene.free()
	quit()
