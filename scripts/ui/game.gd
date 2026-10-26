extends Node3D
var arena_index = 0
var local_multiplayer = false
var selector: Control
var selected_character = "res://assets/characters/X Bot.fbx"
var selected_enemy = "res://assets/characters/Y Bot.fbx"
var stage: Node3D
var ui: CanvasLayer
var player: Fighter
var enemy: Fighter
var camera: CombatCamera
var fighting = false
var ended = false
var paused_panel: PanelContainer
var round_panel: PanelContainer
var preview: Fighter
var menu_camera: Camera3D
var last_menu_character = ""
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	_setup_theme()
	_show_menu()
func _setup_input() -> void:
	var keys = {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "run": KEY_SHIFT, "attack": KEY_J, "special": KEY_K, "guard": KEY_L, "lock_on": KEY_TAB, "pause": KEY_ESCAPE}
	var buttons = {"attack": JOY_BUTTON_X, "special": JOY_BUTTON_Y, "guard": JOY_BUTTON_LEFT_SHOULDER, "run": JOY_BUTTON_RIGHT_SHOULDER, "lock_on": JOY_BUTTON_RIGHT_STICK, "pause": JOY_BUTTON_START}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		if InputMap.action_get_events(action).is_empty():
			var event = InputEventKey.new()
			event.physical_keycode = keys[action]
			InputMap.action_add_event(action, event)
			if buttons.has(action):
				var joy = InputEventJoypadButton.new()
				joy.button_index = buttons[action]
				InputMap.action_add_event(action, joy)
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		var event = InputEventJoypadMotion.new()
		event.axis = JOY_AXIS_LEFT_X if action in ["move_left", "move_right"] else JOY_AXIS_LEFT_Y
		event.axis_value = -1 if action in ["move_left", "move_forward"] else 1
		InputMap.action_add_event(action, event)
	var pause_second = InputEventJoypadButton.new()
	pause_second.device = 1
	pause_second.button_index = JOY_BUTTON_START
	InputMap.action_add_event("pause", pause_second)
	var second_keys = {"move_forward": KEY_UP, "move_back": KEY_DOWN, "move_left": KEY_LEFT, "move_right": KEY_RIGHT, "run": KEY_KP_0, "attack": KEY_KP_1, "special": KEY_KP_2, "guard": KEY_KP_3, "lock_on": KEY_KP_5}
	for action in second_keys:
		var second = "p2_" + action
		if not InputMap.has_action(second): InputMap.add_action(second)
		InputMap.action_erase_events(second)
		var key = InputEventKey.new()
		key.physical_keycode = second_keys[action]
		InputMap.action_add_event(second, key)
		for source in InputMap.action_get_events(action):
			if source is InputEventJoypadButton or source is InputEventJoypadMotion:
				var event = source.duplicate()
				event.device = 1
				InputMap.action_add_event(second, event)
func _setup_theme() -> void:
	var theme = Theme.new()
	theme.default_font_size = 20
	theme.set_color("font_color", "Label", Color("e7f2ff"))
	for type in ["normal", "hover", "pressed", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("142538") if type == "normal" else Color("245575")
		style.border_color = Color("56d8ed")
		style.set_border_width_all(1)
		style.content_margin_left = 22
		style.content_margin_right = 22
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		theme.set_stylebox(type, "Button", style)
	var panel = StyleBoxFlat.new()
	panel.bg_color = Color(0.025, 0.045, 0.08, 0.94)
	panel.set_content_margin_all(30)
	theme.set_stylebox("panel", "PanelContainer", panel)
	var control = Control.new()
	control.name = "ThemeRoot"
	control.theme = theme
	ui = CanvasLayer.new()
	add_child(ui)
	ui.add_child(control)
func _clear() -> void:
	get_tree().paused = false
	if is_instance_valid(stage):
		remove_child(stage)
		stage.queue_free()
	for child in ui.get_child(0).get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	stage = Node3D.new()
	stage.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(stage)
	fighting = false
	ended = false
func _label(parent: Node, text: String, size: int = 20) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label
func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 48)
	parent.add_child(button)
	button.pressed.connect(callback)
	return button
func _panel(position: Vector2, size: Vector2) -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.position = position
	panel.custom_minimum_size = size
	ui.get_child(0).add_child(panel)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	return box
func _show_menu() -> void:
	_clear()
	var arena = ArenaBuilder.new()
	stage.add_child(arena)
	arena.build(arena_index)
	preview = preload("res://scenes/fighter.tscn").instantiate()
	var characters = CharacterCatalog.entries()
	var candidates = characters.filter(func(path): return path != last_menu_character)
	preview.character_path = candidates.pick_random() if not candidates.is_empty() else selected_character
	last_menu_character = preview.character_path
	stage.add_child(preview)
	preview.frozen = true
	preview.rotation.y = -0.4
	menu_camera = Camera3D.new()
	stage.add_child(menu_camera)
	menu_camera.position = Vector3(0, 1.65, 5.0)
	menu_camera.fov = 34.0
	menu_camera.look_at(Vector3(-0.95, 1.16, 0))
	var box = _panel(Vector2(45, 45), Vector2(410, 620))
	var title = _label(box, "THE FIGHT", 62)
	title.name = "MenuTitle"
	title.add_theme_font_override("font", preload("res://assets/fonts/menu_title.tres"))
	title.add_theme_color_override("font_color", Color("fff0c7"))
	title.add_theme_color_override("font_outline_color", Color("101725"))
	title.add_theme_constant_override("outline_size", 5)
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 255
	box.add_child(spacer)
	_button(box, "JOGAR", func(): _show_selection(false)).grab_focus()
	_button(box, "MULTIPLAYER LOCAL", func(): _show_selection(true))
	_button(box, "CONFIGURAÇÕES", _settings)
func _show_selection(multiplayer: bool) -> void:
	local_multiplayer = multiplayer
	_clear()
	selector = preload("res://scripts/ui/character_select.gd").new()
	ui.get_child(0).add_child(selector)
	selector.back.connect(_show_menu)
	selector.selected.connect(func(first: String, second: String):
		selected_character = first
		selected_enemy = second
		_start_fight())
	selector.setup(multiplayer, selected_character, selected_enemy)
func _settings() -> void:
	var box = _panel(Vector2(485, 100), Vector2(450, 260))
	_label(box, "CONFIGURAÇÕES", 28)
	_label(box, "Volume geral")
	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	box.add_child(slider)
	slider.value_changed.connect(func(value): AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value, 0.0001))))
	_label(box, "Câmera automática com lock-on", 16)
	_button(box, "FECHAR", func(): box.get_parent().queue_free())
func _start_fight() -> void:
	_clear()
	arena_index = randi_range(0, ArenaBuilder.NAMES.size() - 1)
	var arena = ArenaBuilder.new()
	stage.add_child(arena)
	arena.build(arena_index)
	player = preload("res://scenes/fighter.tscn").instantiate()
	player.character_path = selected_character
	player.human = true
	player.display_name = selected_character.get_file().get_basename()
	stage.add_child(player)
	player.position = arena.get_node("SpawnPlayer").position
	enemy = preload("res://scenes/fighter.tscn").instantiate()
	enemy.character_path = selected_enemy
	enemy.human = local_multiplayer
	enemy.input_prefix = "p2_"
	enemy.display_name = selected_enemy.get_file().get_basename()
	stage.add_child(enemy)
	enemy.position = arena.get_node("SpawnOpponent").position
	player.opponent = enemy
	enemy.opponent = player
	player.defeated.connect(_finish)
	enemy.defeated.connect(_finish)
	camera = CombatCamera.new()
	stage.add_child(camera)
	camera.player = player
	camera.opponent = enemy
	player.control_camera = camera
	if local_multiplayer: _setup_split_screen()
	player.heavy_hit.connect(func(): camera.shake = 0.18)
	enemy.heavy_hit.connect(func(): camera.shake = 0.18)
	var hud = preload("res://scripts/ui/fight_hud.gd").new()
	ui.get_child(0).add_child(hud)
	hud.setup(player, enemy)
	fighting = true
func _setup_split_screen() -> void:
	var split = HBoxContainer.new()
	split.size = Vector2(1280, 720)
	split.add_theme_constant_override("separation", 2)
	ui.get_child(0).add_child(split)
	for side in 2:
		var container = SubViewportContainer.new()
		container.stretch = true
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		split.add_child(container)
		var viewport = SubViewport.new()
		viewport.size = Vector2i(639, 720)
		viewport.world_3d = stage.get_world_3d()
		container.add_child(viewport)
		var view: CombatCamera
		if side == 0:
			view = camera
			view.reparent(viewport)
		else:
			view = CombatCamera.new()
			viewport.add_child(view)
			view.player = enemy
			view.opponent = player
			enemy.control_camera = view
			player.heavy_hit.connect(func(): view.shake = 0.18)
			enemy.heavy_hit.connect(func(): view.shake = 0.18)
		view.process_mode = Node.PROCESS_MODE_PAUSABLE
		view.current = true
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and fighting and not ended:
		if get_tree().paused:
			get_tree().paused = false
			paused_panel.queue_free()
		else:
			get_tree().paused = true
			var box = _panel(Vector2(470, 220), Vector2(340, 260))
			paused_panel = box.get_parent()
			_label(box, "PAUSA", 32)
			_button(box, "CONTINUAR", func(): get_tree().paused = false; paused_panel.queue_free()).grab_focus()
			_button(box, "REINICIAR", _start_fight)
			_button(box, "MENU", _show_menu)
func _finish(loser: Fighter) -> void:
	if ended: return
	ended = true
	var winner = enemy if loser == player else player
	winner.frozen = true
	var box = _panel(Vector2(460, 230), Vector2(390, 250))
	round_panel = box.get_parent()
	_label(box, "VITÓRIA" if loser == enemy else "DERROTA", 40)
	_label(box, winner.display_name + " venceu", 20)
	_button(box, "REINICIAR", _start_fight).grab_focus()
	_button(box, "VOLTAR AO MENU", _show_menu)
