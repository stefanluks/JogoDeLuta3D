extends Control
var fighters: Array = []
var trailing = [100.0, 100.0]
var elapsed = 0.0
const GOLD = Color("f4c653")
const INK = Color("171321")
func setup(first: Fighter, second: Fighter) -> void:
	fighters = [first, second]
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 2:
		var portrait = preload("res://scripts/ui/character_portrait.gd").new()
		portrait.position = Vector2(22 if i == 0 else 1158, 36)
		portrait.size = Vector2(100, 105)
		add_child(portrait)
		portrait.setup(fighters[i].character_path, false, true)
func _process(delta: float) -> void:
	if fighters.is_empty(): return
	if not get_tree().paused:
		elapsed += delta
		for i in 2:
			trailing[i] = move_toward(trailing[i], fighters[i].health, delta * 20)
	queue_redraw()
func _text(point: Vector2, value: String, size: int, color: Color = Color.WHITE) -> void:
	var font = ThemeDB.fallback_font
	draw_string_outline(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 7, INK)
	draw_string(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
func _draw() -> void:
	if fighters.is_empty(): return
	for i in 2:
		if not is_instance_valid(fighters[i]): return
		draw_set_transform(Vector2(1280 if i == 1 else 0, 0), 0, Vector2(-1 if i == 1 else 1, 1))
		var frame = PackedVector2Array([Vector2(16, 30), Vector2(112, 18), Vector2(310, 30), Vector2(565, 30), Vector2(547, 90), Vector2(130, 90), Vector2(110, 141), Vector2(20, 141)])
		draw_colored_polygon(frame, INK)
		draw_polyline(frame + PackedVector2Array([frame[0]]), GOLD, 5, true)
		draw_style_box(_style(Color("a93022"), Color("ff9238")), Rect2(117, 37, 431, 42))
		draw_rect(Rect2(129, 46, 405, 23), Color("4a1624"))
		draw_rect(Rect2(129, 46, 405 * trailing[i] / 100, 23), Color("ef743b"))
		draw_rect(Rect2(129, 46, 405 * fighters[i].health / 100, 23), Color("c4ed38") if fighters[i].health > 25 else Color("ff4545"))
		draw_rect(Rect2(129, 46, 405 * fighters[i].health / 100, 6), Color(1, 1, 0.65, 0.5))
		draw_style_box(_style(Color("17233f"), GOLD), Rect2(129, 84, 355, 18))
		draw_rect(Rect2(134, 89, 345 * fighters[i].energy / 100, 8), Color("66dcf8"))
		for pip in 3:
			draw_circle(Vector2(155 + pip * 24, 115), 6, GOLD if fighters[i].energy >= (pip + 1) * 25 else Color("3b3546"))
		draw_set_transform(Vector2.ZERO)
		var name = fighters[i].display_name.to_upper()
		var width = ThemeDB.fallback_font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		_text(Vector2(131 if i == 0 else 1149 - width, 142), name, 22)
	_text(Vector2(611, 78), "∞", 52, GOLD)
	_text(Vector2(600, 103), "ROUND 01", 13, GOLD)
func _style(background: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 4
	style.corner_radius_bottom_right = 8
	return style
