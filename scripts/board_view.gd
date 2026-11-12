class_name BoardView
extends Control
## Tablero fascista o liberal dibujado con formas. Se usa en la pantalla de juego.

const FAS_BG := Color("#7a3b1e")
const FAS_SLOT := Color("#4b2010")
const FAS_ACC := Color("#f2c14e")
const LIB_BG := Color("#2f5d6e")
const LIB_SLOT := Color("#1d3d4a")
const LIB_ACC := Color("#9fd8ff")
const CREAM := Color("#f5f0e1")

var kind := "fascist"
var enacted := 0
var powers: Array = []
var tracker := 0
var pulse_index := -1
var pulse := 0.0


func set_board(k: String, n: int, p: Array, t: int) -> void:
	kind = k
	enacted = n
	powers = p
	tracker = t
	custom_minimum_size = Vector2(0, 230.0 if kind == "fascist" else 210.0)
	queue_redraw()


## Destaca una casilla con un pulso (cuando se promulga una política).
func pulse_slot(i: int) -> void:
	pulse_index = i
	pulse = 1.0
	var tw := create_tween()
	tw.tween_property(self, "pulse", 0.0, 0.8)
	tw.tween_callback(_end_pulse)


func _end_pulse() -> void:
	pulse_index = -1
	queue_redraw()


func _process(_delta: float) -> void:
	if pulse_index >= 0:
		queue_redraw()


func _draw() -> void:
	var fas := kind == "fascist"
	var bgc: Color = FAS_BG if fas else LIB_BG
	var slot_c: Color = FAS_SLOT if fas else LIB_SLOT
	var acc: Color = FAS_ACC if fas else LIB_ACC
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), bgc)
	draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), acc, false, 3.0)
	draw_string(font, Vector2(16, 34), "TABLERO FASCISTA" if fas else "TABLERO LIBERAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, acc)

	var n := 6 if fas else 5
	var pad := 14.0
	var cw: float = (size.x - pad * 2.0) / float(n)
	var top := 50.0
	var ch := 100.0 if fas else 84.0
	for i in n:
		var r := Rect2(pad + i * cw + 4.0, top, cw - 8.0, ch)
		var c := r.get_center()
		draw_rect(r, slot_c)
		draw_rect(r, acc, false, 2.0)
		if fas and i == 5:
			_skull(c + Vector2(0, -8), minf(cw, ch) * 0.3, slot_c, acc)
			draw_string(font, Vector2(r.position.x, r.end.y + 16), "Canciller Hitler", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, acc)
			continue
		if i < enacted:
			var fillc := Color("#c0392b") if fas else Color("#2e86c1")
			draw_rect(r.grow(-7.0), fillc)
			draw_string(font, Vector2(c.x - 10, c.y + 9), "F" if fas else "L", HORIZONTAL_ALIGNMENT_CENTER, 20, 28, CREAM)
		elif fas:
			var pw: String = powers[i] if i < powers.size() else ""
			if pw != "":
				_icon(pw, c + Vector2(0, -10), minf(cw, ch) * 0.28, acc)
				var short: String = Txt.POWER_SHORT.get(pw, "")
				if i == 4:
					short = "Ejecución + veto"
				draw_string(font, Vector2(r.position.x, r.end.y + 16), short, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, acc)
		if i == pulse_index:
			draw_rect(r.grow(5.0), Color(acc.r, acc.g, acc.b, pulse), false, 4.0)

	if fas:
		draw_string(font, Vector2(pad, size.y - 12.0), "Hitler canciller tras la 3.ª fascista = victoria fascista", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, acc)
	else:
		draw_string(font, Vector2(pad, size.y - 58.0), Txt.TRACK, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, acc)
		for k in 3:
			var cc := Vector2(pad + 30.0 + k * 90.0, size.y - 24.0)
			draw_circle(cc, 13.0, slot_c)
			if k < tracker:
				draw_circle(cc, 9.0, acc)
			draw_arc(cc, 13.0, 0.0, TAU, 24, acc, 2.0)
		draw_string(font, Vector2(pad + 300.0, size.y - 18.0), "3 fracasos: se promulga la cima", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, acc)


func _skull(c: Vector2, s: float, bg: Color, acc: Color) -> void:
	draw_circle(c, s, acc)
	draw_rect(Rect2(c.x - s * 0.5, c.y + s * 0.4, s, s * 0.45), acc)
	draw_circle(c + Vector2(-s * 0.4, -s * 0.1), s * 0.28, bg)
	draw_circle(c + Vector2(s * 0.4, -s * 0.1), s * 0.28, bg)


func _icon(ic: String, c: Vector2, s: float, col: Color) -> void:
	match ic:
		"peek":
			for k in 3:
				draw_rect(Rect2(c.x - s * 0.4 + k * 3.0, c.y - s * 0.4 + k * s * 0.25, s * 0.8, s * 0.45), col, false, 2.5)
		"investigate":
			draw_arc(c + Vector2(-s * 0.1, -s * 0.1), s * 0.3, 0.0, TAU, 28, col, 3.0)
			draw_line(c + Vector2(s * 0.12, s * 0.12), c + Vector2(s * 0.45, s * 0.45), col, 4.0)
		"special":
			draw_circle(c + Vector2(0, -s * 0.25), s * 0.16, col)
			draw_circle(c + Vector2(-s * 0.3, s * 0.2), s * 0.16, col)
			draw_circle(c + Vector2(s * 0.3, s * 0.2), s * 0.16, col)
		"execute":
			draw_rect(Rect2(c.x - s * 0.35, c.y - s * 0.12, s * 0.5, s * 0.24), col)
			draw_colored_polygon(PackedVector2Array([
				Vector2(c.x + s * 0.15, c.y - s * 0.12),
				Vector2(c.x + s * 0.4, c.y),
				Vector2(c.x + s * 0.15, c.y + s * 0.12)]), col)
		_:
			pass


## Posición local del centro de una casilla (para que una carta vuele hasta ella).
func slot_pos(i: int) -> Vector2:
	var n := 6 if kind == "fascist" else 5
	var pad := 14.0
	var cw: float = (size.x - pad * 2.0) / float(n)
	var ch := 100.0 if kind == "fascist" else 84.0
	return Vector2(pad + i * cw + cw * 0.5, 50.0 + ch * 0.5)


func set_enacted(n: int) -> void:
	enacted = n
	queue_redraw()
