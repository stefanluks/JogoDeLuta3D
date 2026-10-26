class_name SharedAnimation
extends RefCounted
const CLIPS = {"Idle": "Idle", "Walk": "Walking", "Run": "Running (1)", "Punch1": "Punching", "Punch2": "Punching (1)", "Finisher": "Punching", "Spell": "Standing 1H Magic Attack 01", "Guard": "Standing Block Idle", "Hit": "Head Hit", "Reaction": "Reaction", "Defeat": "Standing React Death Right"}
static var sources: Dictionary = {}
static func install(model: Node3D) -> Dictionary:
	var skeletons = model.find_children("*", "Skeleton3D", true, false)
	if skeletons.is_empty():
		push_error("Character requires Skeleton3D: " + model.name)
		return {}
	var target: Skeleton3D = skeletons[0]
	for old in model.find_children("*", "AnimationPlayer", true, false):
		old.get_parent().remove_child(old)
		old.queue_free()
	var player = AnimationPlayer.new()
	player.name = "SharedAnimationPlayer"
	model.add_child(player)
	var library = AnimationLibrary.new()
	var bones: Dictionary = {}
	for i in target.get_bone_count(): bones[CharacterCatalog.bone_key(target.get_bone_name(i))] = i
	for state in CLIPS:
		var file: String = CLIPS[state]
		if not sources.has(file):
			var source = load("res://assets/animations/" + file + ".fbx").instantiate()
			var sk: Skeleton3D = source.find_children("*", "Skeleton3D", true, false)[0]
			var ap: AnimationPlayer = source.find_children("*", "AnimationPlayer", true, false)[0]
			var rests = {}
			for i in sk.get_bone_count(): rests[sk.get_bone_name(i)] = sk.get_bone_rest(i)
			sources[file] = [ap.get_animation("mixamo_com").duplicate(true), rests]
			source.free()
		var animation: Animation = sources[file][0].duplicate(true)
		for track in range(animation.get_track_count() - 1, -1, -1):
			var path = animation.track_get_path(track)
			var source_name = String(path.get_subname(0)) if path.get_subname_count() else ""
			var key = CharacterCatalog.bone_key(source_name)
			if not bones.has(key):
				animation.remove_track(track)
				continue
			var bone: int = bones[key]
			animation.track_set_path(track, NodePath(String(model.get_path_to(target)) + ":" + target.get_bone_name(bone)))
			var rest = target.get_bone_rest(bone)
			var source_rest: Transform3D = sources[file][1][source_name]
			for k in animation.track_get_key_count(track):
				if animation.track_get_type(track) == Animation.TYPE_POSITION_3D:
					animation.track_set_key_value(track, k, rest.origin)
				elif animation.track_get_type(track) == Animation.TYPE_ROTATION_3D:
					var rotation: Quaternion = animation.track_get_key_value(track, k)
					animation.track_set_key_value(track, k, rest.basis.get_rotation_quaternion() * source_rest.basis.get_rotation_quaternion().inverse() * rotation)
		animation.loop_mode = Animation.LOOP_LINEAR if state in ["Idle", "Walk", "Run", "Guard"] else Animation.LOOP_NONE
		library.add_animation(state, animation)
	player.add_animation_library("", library)
	var machine = AnimationNodeStateMachine.new()
	var index = 0
	for state in CLIPS:
		var node = AnimationNodeAnimation.new()
		node.animation = state
		machine.add_node(state, node, Vector2(index % 4, index / 4) * 200)
		index += 1
	for from in CLIPS:
		for to in CLIPS:
			if from == to: continue
			var transition = AnimationNodeStateMachineTransition.new()
			transition.xfade_time = 0.1
			machine.add_transition(from, to, transition)
	var tree = AnimationTree.new()
	tree.name = "AnimationTree"
	model.add_child(tree)
	tree.anim_player = tree.get_path_to(player)
	tree.tree_root = machine
	tree.active = true
	var playback: AnimationNodeStateMachinePlayback = tree.get("parameters/playback")
	playback.start("Idle")
	return {"tree": tree, "playback": playback, "player": player, "skeleton": target}
