class_name PileView
extends Control
## Pila de cartas boca abajo, apiladas y con su reverso. Pulsa cuando cambia el número de cartas.

var count := 0
var title := ""


func _ready() -> void:
	custom_minimum_size = Vector2(120, 170)
	pivot_offset = Vector2(60, 85)


func set_pile(c: int, t: String) -> void:
	var changed := c != count
	count = c
	title = t
	queue_redraw()
	if changed and is_inside_tree():
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.1, 1.1), 0.12)
		tw.tween_property(self, "scale", Vector2.ONE, 0.18)


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var base := Rect2(Vector2(12, 26), Vector2(96, 128))
	if count == 0:
		draw_rect(base, Color("#8aa0b8"), false, 1.5)
	for k in mini(count, 8):
		PolicyCard.draw_back(self, Rect2(base.position + Vector2(k * 1.2, k * 1.2), base.size))
	draw_string(font, Vector2(4, 16), title, HORIZONTAL_ALIGNMENT_CENTER, 112, 13, Color("#f5f0e1"))
	draw_string(font, Vector2(4, 166), str(count), HORIZONTAL_ALIGNMENT_CENTER, 112, 18, Color("#f2c14e"))
