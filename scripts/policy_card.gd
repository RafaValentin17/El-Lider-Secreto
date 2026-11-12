class_name PolicyCard
extends Control
## Carta: política liberal/fascista, carta de rol o etiqueta (para votar). Con animaciones.

const BLUE := Color("#1f5f9e")
const RED := Color("#a3262b")
const DARK := Color("#3b0d0d")
const CREAM := Color("#f5f0e1")
const INK := Color("#2b1d0e")
const GOLD := Color("#c9a227")

var mode := "policy"       # policy | role | label
var kind := "L"
var role := ""
var label_text := ""
var label_col := Color.WHITE
var face_up := true


func setup(k: String, up: bool = true, sz: Vector2 = Vector2(96, 136)) -> void:
	mode = "policy"
	kind = k
	face_up = up
	_init_size(sz)


func setup_label(text: String, col: Color, sz: Vector2 = Vector2(150, 200)) -> void:
	mode = "label"
	label_text = text
	label_col = col
	face_up = true
	_init_size(sz)


func _init_size(sz: Vector2) -> void:
	custom_minimum_size = sz
	size = sz
	pivot_offset = sz * 0.5
	queue_redraw()


## Gira la carta cambiando su contenido a mitad del giro.
func flip_to(k: String, up: bool) -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale:x", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_apply.bind(k, up))
	tw.tween_property(self, "scale:x", 1.0, 0.14).set_trans(Tween.TRANS_SINE)


## Gira la carta y la deja mostrando el rol.
func reveal_role(r: String) -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale:x", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_set_role.bind(r))
	tw.tween_property(self, "scale:x", 1.0, 0.14).set_trans(Tween.TRANS_SINE)


## Entra desde pequeña con rebote. Llamar cuando la carta ya está en el árbol.
func pop_in(delay: float = 0.0) -> void:
	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.25)


func _apply(k: String, up: bool) -> void:
	mode = "policy"
	kind = k
	face_up = up
	queue_redraw()


func _set_role(r: String) -> void:
	mode = "role"
	role = r
	face_up = true
	queue_redraw()


## Reverso de carta con patrón dorado. Lo usan las cartas y las pilas.
static func draw_back(ci: CanvasItem, r: Rect2) -> void:
	ci.draw_rect(r, Color("#1b2a4a"))
	ci.draw_rect(r.grow(-5.0), Color(0.79, 0.64, 0.15, 0.9), false, 2.0)
	var x := 12.0
	while x < r.size.x - 8.0:
		var y := 12.0
		while y < r.size.y - 8.0:
			ci.draw_circle(r.position + Vector2(x, y), 1.8, Color(0.79, 0.64, 0.15, 0.35))
			y += 14.0
		x += 14.0
	var c := r.get_center()
	ci.draw_circle(c, r.size.x * 0.24, Color(0.79, 0.64, 0.15, 0.9))
	ci.draw_circle(c, r.size.x * 0.17, Color("#1b2a4a"))
	ci.draw_circle(c, r.size.x * 0.1, Color(0.79, 0.64, 0.15, 0.9))


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if not face_up:
		draw_back(self, r)
		return
	match mode:
		"role":
			_draw_role(r)
		"label":
			_draw_label(r)
		_:
			_draw_policy(r)


func _draw_policy(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var is_lib := kind == "L"
	var base: Color = BLUE if is_lib else RED
	draw_rect(r, base)
	draw_rect(r, INK, false, 4.0)
	draw_rect(r.grow(-5.0), CREAM)
	draw_rect(Rect2(Vector2(5, 5), Vector2(size.x - 10, 28)), base)
	draw_string(font, Vector2(8, 25), "LIBERAL" if is_lib else "FASCISTA", HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 13, CREAM)
	var c := Vector2(size.x * 0.5, size.y * 0.5 + 8.0)
	var s := minf(size.x, size.y) / 96.0
	if is_lib:
		draw_circle(c, 22.0 * s, base)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-22, 0) * s, c + Vector2(-38, -14) * s, c + Vector2(-30, 10) * s]), base)
		draw_colored_polygon(PackedVector2Array([c + Vector2(22, 0) * s, c + Vector2(38, -14) * s, c + Vector2(30, 10) * s]), base)
	else:
		draw_line(c + Vector2(-20, -20) * s, c + Vector2(20, 20) * s, base, 6.0 * s)
		draw_line(c + Vector2(20, -20) * s, c + Vector2(-20, 20) * s, base, 6.0 * s)
		draw_circle(c, 10.0 * s, base)
	draw_string(font, Vector2(6, size.y - 12), Txt.LIB_POL if is_lib else Txt.FAS_POL, HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 11, base)


func _draw_role(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var col: Color = BLUE if role == "liberal" else (RED if role == "fascist" else DARK)
	draw_rect(r, col)
	draw_rect(r, INK, false, 4.0)
	draw_rect(r.grow(-6.0), CREAM)
	draw_rect(Rect2(Vector2(6, 6), Vector2(size.x - 12, 40)), col)
	draw_string(font, Vector2(6, 34), "Tu rol secreto", HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 16, CREAM)
	var c := Vector2(size.x * 0.5, size.y * 0.42)
	if role == "liberal":
		draw_circle(c, 34.0, BLUE)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-34, 0), c + Vector2(-54, -18), c + Vector2(-46, 14)]), BLUE)
		draw_colored_polygon(PackedVector2Array([c + Vector2(34, 0), c + Vector2(54, -18), c + Vector2(46, 14)]), BLUE)
	elif role == "fascist":
		draw_line(c + Vector2(-30, -30), c + Vector2(30, 30), RED, 9.0)
		draw_line(c + Vector2(30, -30), c + Vector2(-30, 30), RED, 9.0)
		draw_circle(c, 12.0, RED)
	else:
		draw_circle(c, 34.0, DARK)
		draw_circle(c + Vector2(-12, -4), 8.0, CREAM)
		draw_circle(c + Vector2(12, -4), 8.0, CREAM)
	draw_string(font, Vector2(6, size.y * 0.72), Txt.ROLE_NAME[role], HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 22, col)


func _draw_label(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	draw_rect(r, label_col)
	draw_rect(r, INK, false, 4.0)
	draw_rect(r.grow(-6.0), label_col.darkened(0.25), false, 3.0)
	draw_string(font, Vector2(8, size.y * 0.52), label_text, HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 30, CREAM)
	draw_string(font, Vector2(8, size.y - 16), "▲ desliza", HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 14, CREAM)
