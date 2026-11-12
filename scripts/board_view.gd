class_name BoardView
extends Control
## Tablero fascista o liberal dibujado con formas. Se usa en la pantalla de juego.

const FAS_BG := Color("#121212")
const FAS_SLOT := Color("#2e2e2e")
const FAS_ACC := Color("#c9a227")
const LIB_BG := Color("#f4f1ea")
const LIB_SLOT := Color("#ddd6c4")
const LIB_ACC := Color("#3b2a1a")
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
	custom_minimum_size = Vector2(0, 300.0 if kind == "fascist" else 200.0)
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
	draw_rect(Rect2(Vector2(10, 10), size - Vector2(20, 20)), acc, false, 1.0)
	draw_string(font, Vector2(16, 34), "TABLERO TIRANO" if fas else "TABLERO LIBERTADOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, acc)

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
			PolicyCard.draw_symbol(self, "crown", c, 0.9, acc)
			draw_multiline_string(font, Vector2(r.position.x, r.end.y + 16), "Consejero El Esclavista", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, -1, acc)
			continue
		if i < enacted:
			var fillc := Color("#c0392b") if fas else Color("#2e86c1")
			draw_rect(r.grow(-7.0), fillc)
		elif not fas and i == 4:
			PolicyCard.draw_symbol(self, "cap", c, 0.9, acc)
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
		draw_multiline_string(font, Vector2(pad, 212.0), "Si El Esclavista es elegido Consejero tras la tercera política tirana, los TIRANOS ganan automáticamente.", HORIZONTAL_ALIGNMENT_CENTER, size.x - pad * 2.0, 15, -1, acc)
	else:
		draw_multiline_string(font, Vector2(pad, 160.0), "Si El Esclavista es ejecutado, los LIBERTADORES ganan automáticamente.", HORIZONTAL_ALIGNMENT_CENTER, size.x - pad * 2.0, 15, -1, acc)


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
