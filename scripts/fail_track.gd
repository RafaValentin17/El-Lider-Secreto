class_name FailTrack
extends Control
## Marcador de fracasos seguidos del gobierno. Va en su propio recuadro, justo debajo del tablero liberal.

const BG := Color("#8b1e1e")
const SLOT := Color("#4a0d0d")
const ACC := Color("#f2c14e")

var tracker := 0


func set_tracker(t: int) -> void:
	tracker = t
	custom_minimum_size = Vector2(0, 104)
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var w := size.x
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), ACC, false, 3.0)
	draw_string(font, Vector2(14, 30), Txt.TRACK, HORIZONTAL_ALIGNMENT_LEFT, w - 28.0, 15, ACC)
	for k in 3:
		var cc := Vector2(w * 0.5 + (k - 1) * 80.0, 62.0)
		draw_circle(cc, 13.0, SLOT)
		if k < tracker:
			draw_circle(cc, 9.0, ACC)
		draw_arc(cc, 13.0, 0.0, TAU, 24, ACC, 2.0)
	draw_string(font, Vector2(0, 94), "3 fracasos: se promulga la cima", HORIZONTAL_ALIGNMENT_CENTER, w, 13, ACC)
