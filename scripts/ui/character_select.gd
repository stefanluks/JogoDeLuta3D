extends Control
signal selected(first: String, second: String)
signal back
var local_mode = false
var roster: Array[String] = []
var cursors = [0, 0]
var confirmed = [false, false]
var tiles: Array = [[], []]
var previews: Array = [null, null]
var names: Array = [null, null]
var preview_hosts: Array = []
var ready_button: Button
var active_slot = 0
func setup(multiplayer: bool, first: String, second: String) -> void:
	local_mode = multiplayer
	roster = CharacterCatalog.entries()
	cursors = [maxi(0, roster.find(first)), maxi(0, roster.find(second))]
	var background = ColorRect.new()
	background.color = Color("101827")
	background.size = Vector2(1280, 720)
	add_child(background)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var heading = Label.new()
	heading.position = Vector2(0, 20)
	heading.size.x = 1280
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.text = "VERSUS LOCAL / CHARACTER SELECT" if local_mode else "CHARACTER SELECT"
	heading.add_theme_font_size_override("font_size", 32)
	add_child(heading)
	for side in 2:
		var title = Label.new()
		title.position = Vector2(40 + side * 950, 82)
		title.text = "PLAYER 1" if side == 0 else ("PLAYER 2" if local_mode else "CPU")
		title.modulate = Color("61dfff") if side == 0 else Color("ffac50")
		title.add_theme_font_size_override("font_size", 26)
		add_child(title)
		var host = Control.new()
		host.position = Vector2(15 + side * 935, 115)
		host.size = Vector2(330, 420)
		add_child(host)
		preview_hosts.append(host)
		var label = Label.new()
		label.position = Vector2(25 + side * 930, 535)
		label.size = Vector2(330, 55)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 23)
		add_child(label)
		names[side] = label
	if local_mode:
		_build_grid(0, Vector2(355, 150), 3)
		_build_grid(1, Vector2(670, 150), 3)
	else:
		_build_grid(0, Vector2(460, 150), 3)
		var switch = Button.new()
		switch.position = Vector2(465, 470)
		switch.size = Vector2(350, 45)
		switch.text = "ALTERNAR: JOGADOR / CPU [TAB]"
		switch.pressed.connect(_switch_slot)
		add_child(switch)
	for side in 2: _update_preview(side)
	ready_button = Button.new()
	ready_button.position = Vector2(465, 565)
	ready_button.size = Vector2(350, 55)
	ready_button.text = "CONFIRMAR P1 / P2" if local_mode else "CONFIRMAR PERSONAGEM"
	ready_button.pressed.connect(func(): _confirm(active_slot))
	add_child(ready_button)
	var cancel = Button.new()
	cancel.position = Vector2(40, 640)
	cancel.size = Vector2(200, 45)
	cancel.text = "VOLTAR [ESC]"
	cancel.pressed.connect(func(): back.emit())
	add_child(cancel)
	var help = Label.new()
	help.position = Vector2(280, 640)
	help.text = "P1: WASD + J   P2: SETAS + NUM 1   |   A confirmar / B desfazer\nArena sorteada ao iniciar a luta"
	help.add_theme_font_size_override("font_size", 18)
	add_child(help)
	_refresh_tiles()
func _build_grid(side: int, origin: Vector2, columns: int) -> void:
	for i in roster.size():
		var tile = Button.new()
		tile.position = origin + Vector2(i % columns * 96, i / columns * 130)
		tile.size = Vector2(92, 124)
		tile.focus_mode = Control.FOCUS_NONE
		add_child(tile)
		var portrait = preload("res://scripts/ui/character_portrait.gd").new()
		portrait.position = Vector2(4, 4)
		portrait.size = Vector2(84, 90)
		tile.add_child(portrait)
		portrait.setup(roster[i], false, true)
		var nameplate = Label.new()
		nameplate.position = Vector2(3, 95)
		nameplate.size = Vector2(86, 25)
		nameplate.clip_text = true
		nameplate.text = roster[i].get_file().get_basename()
		nameplate.add_theme_font_size_override("font_size", 12)
		nameplate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(nameplate)
		tile.pressed.connect(func():
			var slot = side if local_mode else active_slot
			confirmed[slot] = false
			cursors[slot] = i
			active_slot = slot
			_update_preview(slot)
			_refresh_tiles())
		tiles[side].append(tile)
func _update_preview(side: int) -> void:
	if is_instance_valid(previews[side]):
		preview_hosts[side].remove_child(previews[side])
		previews[side].queue_free()
	var portrait = preload("res://scripts/ui/character_portrait.gd").new()
	portrait.size = Vector2(330, 420)
	preview_hosts[side].add_child(portrait)
	portrait.setup(roster[cursors[side]])
	previews[side] = portrait
	names[side].text = roster[cursors[side]].get_file().get_basename().to_upper() + ("\nREADY" if confirmed[side] else "")
func _refresh_tiles() -> void:
	for grid in 2:
		var slot = grid if local_mode else active_slot
		for i in tiles[grid].size():
			var tile: Button = tiles[grid][i]
			var style = StyleBoxFlat.new()
			style.bg_color = Color("293d50")
			style.border_color = (Color("61dfff") if slot == 0 else Color("ffac50")) if cursors[slot] == i else Color("6d6656")
			style.set_border_width_all(4 if cursors[slot] == i else 1)
			tile.add_theme_stylebox_override("normal", style)
			tile.add_theme_stylebox_override("hover", style)
	queue_redraw()
func _switch_slot() -> void:
	active_slot = 1 - active_slot
	_refresh_tiles()
func _confirm(side: int) -> void:
	confirmed[side] = true
	_update_preview(side)
	if confirmed[0] and confirmed[1]:
		selected.emit(roster[cursors[0]], roster[cursors[1]])
	else:
		active_slot = 1 - side
		ready_button.text = "CONFIRMAR P2" if active_slot == 1 else "CONFIRMAR P1"
		_refresh_tiles()
func _input(event: InputEvent) -> void:
	var viewport = get_viewport()
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("pause"):
		back.emit()
		viewport.set_input_as_handled()
		return
	var side = 0 if local_mode else active_slot
	if local_mode and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		if event.device > 1: return
		side = event.device
	if local_mode and event is InputEventKey:
		side = 1 if event.physical_keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_KP_1, KEY_KP_ENTER] else 0
	var prefix = "p2_" if side == 1 and local_mode else ""
	var offset = 0
	if not local_mode:
		if event.is_action_pressed("ui_left"): offset = -1
		if event.is_action_pressed("ui_right"): offset = 1
		if event.is_action_pressed("ui_up"): offset = -3
		if event.is_action_pressed("ui_down"): offset = 3
	if event.is_action_pressed(prefix + "move_left"): offset = -1
	if event.is_action_pressed(prefix + "move_right"): offset = 1
	if event.is_action_pressed(prefix + "move_forward"): offset = -3
	if event.is_action_pressed(prefix + "move_back"): offset = 3
	if offset != 0 and not confirmed[side]:
		cursors[side] = posmod(cursors[side] + offset, roster.size())
		_update_preview(side)
		_refresh_tiles()
		viewport.set_input_as_handled()
	var confirm = event.is_action_pressed(prefix + "attack")
	if event is InputEventKey: confirm = confirm or (event.pressed and event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER])
	if event is InputEventJoypadButton: confirm = confirm or (event.pressed and event.button_index == JOY_BUTTON_A)
	if confirm:
		_confirm(side)
		viewport.set_input_as_handled()
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B:
		confirmed[side] = false
		_update_preview(side)
		viewport.set_input_as_handled()
	if not local_mode and event.is_action_pressed("lock_on"): _switch_slot()
