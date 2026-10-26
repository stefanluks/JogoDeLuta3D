extends Node3D
var arena_index = 0
var selected_character = "res://assets/characters/X Bot.fbx"
var selected_enemy = "res://assets/characters/Y Bot.fbx"
var stage: Node3D
var ui: CanvasLayer
var player: Fighter
var enemy: Fighter
var camera: CombatCamera
var status: Label
var bars: Array[ProgressBar] = []
var fighting = false
var ended = false
var paused_panel: PanelContainer
var round_panel: PanelContainer
var preview: Fighter
var menu_camera: Camera3D
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
	bars.clear()
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
	preview.character_path = selected_character
	stage.add_child(preview)
	preview.frozen = true
	preview.rotation.y = -0.4
	menu_camera = Camera3D.new()
	stage.add_child(menu_camera)
	menu_camera.position = Vector3(-3.5, 2.1, 6.3)
	menu_camera.look_at(Vector3(-1.15, 1, 0))
	var box = _panel(Vector2(45, 45), Vector2(410, 620))
	_label(box, "THE FIGHT", 52)
	_label(box, "PULSE / ARENA PROTOCOL", 16)
	_label(box, "Combate terrestre • Protótipo 3D", 16)
	_button(box, "JOGAR", _start_fight).grab_focus()
	_label(box, "ARENA", 15)
	var arenas = OptionButton.new()
	for title in ArenaBuilder.NAMES: arenas.add_item(title)
	arenas.select(arena_index)
	box.add_child(arenas)
	arenas.item_selected.connect(func(index): arena_index = index; _show_menu())
	_character_picker(box, "SEU PERSONAGEM", selected_character, true)
	_character_picker(box, "ADVERSÁRIO", selected_enemy, false)
	_button(box, "CONFIGURAÇÕES", _settings)
	_button(box, "SAIR", func(): get_tree().quit())
func _character_picker(box: VBoxContainer, title: String, selected: String, is_player: bool) -> void:
	_label(box, title, 15)
	var picker = OptionButton.new()
	var characters = CharacterCatalog.entries()
	for path in characters: picker.add_item(path.get_file().get_basename())
	picker.select(maxi(0, characters.find(selected)))
	box.add_child(picker)
	picker.item_selected.connect(func(index):
		if is_player:
			selected_character = characters[index]
			_show_menu()
		else: selected_enemy = characters[index])
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
	player.heavy_hit.connect(func(): camera.shake = 0.18)
	enemy.heavy_hit.connect(func(): camera.shake = 0.18)
	var hud = _panel(Vector2(25, 20), Vector2(500, 180))
	for fighter in [player, enemy]:
		_label(hud, fighter.display_name, 18)
		for color in [Color("65e4bc"), Color("52b8f3")]:
			var bar = ProgressBar.new()
			bar.custom_minimum_size = Vector2(430, 13)
			bar.show_percentage = false
			var fill = StyleBoxFlat.new()
			fill.bg_color = color
			bar.add_theme_stylebox_override("fill", fill)
			hud.add_child(bar)
			bars.append(bar)
	status = _label(hud, "", 14)
	var help = _panel(Vector2(25, 640), Vector2(850, 40))
	_label(help, "WASD mover   SHIFT correr   J combo   K energia   L escudo   TAB lock-on   ESC pausa", 16)
	fighting = true
func _process(_delta: float) -> void:
	if fighting and is_instance_valid(player):
		bars[0].value = player.health
		bars[1].value = player.energy
		bars[2].value = enemy.health
		bars[3].value = enemy.energy
		status.text = "%s  /  %s  •  %s" % [player.state, enemy.state, "LOCK-ON" if player.lock_on else "LIVRE"]
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
