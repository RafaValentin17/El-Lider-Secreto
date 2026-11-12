class_name PolicyCard
extends Control
## Carta: política liberal/fascista, carta de rol o etiqueta (para votar). Con animaciones.

const BLUE := Color("#1f5f9e")
const RED := Color("#a3262b")
const DARK := Color("#3b0d0d")
const CREAM := Color("#f5f0e1")
const INK := Color("#2b1d0e")
const GOLD := Color("#c9a227")
const GOLD_BACK := Color("#d4af37")

var mode := "policy"       # policy | role | label
var kind := "L"
var role := ""
var label_text := ""
var label_col := Color.WHITE
var face_up := true
var is_thumb := false
var thumb_up := true


func setup(k: String, up: bool = true, sz: Vector2 = Vector2(96, 136)) -> void:
	mode = "policy"
	kind = k
	face_up = up
	_init_size(sz)


func setup_thumb(up: bool, sz: Vector2 = Vector2(150, 200)) -> void:
	mode = "label"
	is_thumb = true
	thumb_up = up
	label_text = Txt.JA if up else Txt.NEIN
	face_up = true
	_init_size(sz)


func setup_label(text: String, col: Color, sz: Vector2 = Vector2(150, 200)) -> void:
	mode = "label"
	is_thumb = false
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
	# Negro victoriano con relieve: bisel claro arriba-izquierda y sombra abajo-derecha.
	ci.draw_rect(r, Color("#0b0b0b"))
	ci.draw_rect(Rect2(r.position + Vector2(6, 6), r.size - Vector2(12, 12)), Color("#1c1c1c"))
	ci.draw_line(r.position + Vector2(6, r.size.y - 6), r.position + Vector2(6, 6), Color("#2e2e2e"), 3.0)
	ci.draw_line(r.position + Vector2(6, 6), r.position + Vector2(r.size.x - 6, 6), Color("#2e2e2e"), 3.0)
	ci.draw_line(r.position + Vector2(r.size.x - 6, 6), r.position + Vector2(r.size.x - 6, r.size.y - 6), Color("#050505"), 3.0)
	ci.draw_line(r.position + Vector2(r.size.x - 6, r.size.y - 6), r.position + Vector2(6, r.size.y - 6), Color("#050505"), 3.0)
	# Borde dorado.
	ci.draw_rect(r.grow(-2.0), GOLD_BACK, false, 3.0)
	ci.draw_rect(r.grow(-10.0), Color(0.79, 0.64, 0.15, 0.5), false, 1.0)
	# Motivo central: rombo con volutas doradas y un medallón.
	var c := r.get_center()
	var k := minf(r.size.x, r.size.y) * 0.3
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k), c + Vector2(k * 0.6, 0), c + Vector2(0, k), c + Vector2(-k * 0.6, 0)]), Color(0.79, 0.64, 0.15, 0.25))
	ci.draw_polyline(PackedVector2Array([c + Vector2(0, -k), c + Vector2(k * 0.6, 0), c + Vector2(0, k), c + Vector2(-k * 0.6, 0), c + Vector2(0, -k)]), GOLD_BACK, 2.0)
	ci.draw_arc(c, k * 0.42, 0.0, TAU, 28, GOLD_BACK, 2.0)
	ci.draw_circle(c, 4.0, GOLD_BACK)
	# Franja de arabescos en las esquinas.
	for corner in [Vector2(20, 20), Vector2(r.size.x - 20, 20), Vector2(20, r.size.y - 20), Vector2(r.size.x - 20, r.size.y - 20)]:
		ci.draw_arc(r.position + corner, 9.0, 0.0, TAU, 16, Color(0.79, 0.64, 0.15, 0.6), 1.5)
		ci.draw_circle(r.position + corner, 2.5, GOLD_BACK)


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


const BLACK := Color("#0d0d0d")
const ACC_LIB := Color("#9fd8ff")
const ACC_FAS := Color("#e0463c")
const ACC_HIT := Color("#f2c14e")
const FIST := Color("#d9b26a")


func _draw_policy(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var is_lib := kind == "L"
	var acc: Color = ACC_LIB if is_lib else ACC_FAS
	draw_rect(r, BLACK)
	draw_rect(r, acc, false, 3.0)
	draw_rect(r.grow(-6.0), acc, false, 1.5)
	draw_rect(Rect2(Vector2(8, 8), Vector2(size.x - 16, 28)), Color("#1c1c1c"))
	draw_string(font, Vector2(8, 27), "LIBERTADOR" if is_lib else "TIRANO", HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 13, acc)
	var c := Vector2(size.x * 0.5, size.y * 0.5 + 8.0)
	var s := minf(size.x, size.y) / 96.0
	draw_symbol(self, "cap" if is_lib else "crown", c, 1.0 * s, acc)
	draw_string(font, Vector2(6, size.y - 12), Txt.LIB_POL if is_lib else Txt.FAS_POL, HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 11, acc)


func _draw_role(r: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var acc: Color = ACC_LIB if role == "liberal" else (ACC_FAS if role == "fascist" else ACC_HIT)
	draw_rect(r, BLACK)
	draw_rect(r, acc, false, 3.0)
	draw_rect(r.grow(-6.0), acc, false, 1.5)
	draw_rect(Rect2(Vector2(8, 8), Vector2(size.x - 16, 36)), Color("#1c1c1c"))
	draw_string(font, Vector2(6, 33), "Tu rol secreto", HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 16, acc)
	var c := Vector2(size.x * 0.5, size.y * 0.42)
	var sym := "cap" if role == "liberal" else ("crown" if role == "fascist" else "chain")
	draw_symbol(self, sym, c, 1.6, acc)
	draw_string(font, Vector2(6, size.y * 0.72), Txt.ROLE_NAME[role], HORIZONTAL_ALIGNMENT_CENTER, size.x - 12, 22, acc)


func _draw_label(r: Rect2) -> void:
	if is_thumb:
		_draw_thumb(r)
		return
	var font := ThemeDB.fallback_font
	draw_rect(r, label_col)
	draw_rect(r, INK, false, 4.0)
	draw_rect(r.grow(-6.0), label_col.darkened(0.25), false, 3.0)
	draw_string(font, Vector2(8, size.y * 0.52), label_text, HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 30, CREAM)
	draw_string(font, Vector2(8, size.y - 16), "▲ desliza", HORIZONTAL_ALIGNMENT_CENTER, size.x - 16, 14, CREAM)


## Puño con el pulgar hacia arriba (sí, verde) o hacia abajo (no, rojo). Sin texto.
func _draw_thumb(r: Rect2) -> void:
	var acc: Color = Color("#3fbf6a") if thumb_up else Color("#e0463c")
	draw_rect(r, BLACK)
	draw_rect(r, acc, false, 3.0)
	draw_rect(r.grow(-6.0), acc, false, 1.5)
	var c := Vector2(size.x * 0.5, size.y * 0.5)
	var outline := Color("#1a1208")
	# Puño: cuatro dedos apilados sobre la palma.
	var palm := Rect2(c.x - 40.0, c.y - 30.0, 80.0, 66.0)
	draw_rect(palm, FIST)
	draw_rect(palm, outline, false, 3.0)
	for k in range(1, 4):
		var yy := palm.position.y + k * 16.5
		draw_line(Vector2(palm.position.x + 6.0, yy), Vector2(palm.end.x - 6.0, yy), outline, 2.5)
	for k in range(4):
		var yy2 := palm.position.y + 4.0 + k * 16.5
		draw_line(Vector2(palm.end.x - 2.0, yy2), Vector2(palm.end.x - 2.0, yy2 + 12.0), outline, 1.5)
	# Pulgar, sacado hacia arriba o hacia abajo, con uña.
	var tcx := c.x - 26.0
	var ty := c.y - 30.0 if thumb_up else c.y + 36.0
	var tip_y := c.y - 66.0 if thumb_up else c.y + 66.0
	draw_rect(Rect2(tcx - 14.0, minf(ty, tip_y + 14.0), 28.0, absf(ty - tip_y) - 14.0 + 2.0), FIST)
	draw_circle(Vector2(tcx, tip_y + (14.0 if thumb_up else -14.0)), 14.0, FIST)
	draw_arc(Vector2(tcx, tip_y + (14.0 if thumb_up else -14.0)), 14.0, 0.0, TAU, 24, outline, 3.0)
	draw_line(Vector2(tcx - 14.0, ty), Vector2(tcx - 14.0, tip_y + (14.0 if thumb_up else -14.0)), outline, 2.5)
	draw_line(Vector2(tcx + 14.0, ty), Vector2(tcx + 14.0, tip_y + (14.0 if thumb_up else -14.0)), outline, 2.5)
	draw_line(Vector2(tcx - 7.0, tip_y + (4.0 if thumb_up else -4.0)), Vector2(tcx + 7.0, tip_y + (4.0 if thumb_up else -4.0)), outline, 2.0)
	# Muñeca con puño de encaje en el color de la carta.
	var cuff_y := c.y + 40.0 if thumb_up else c.y - 58.0
	draw_rect(Rect2(c.x - 50.0, cuff_y, 100.0, 18.0), acc)
	draw_rect(Rect2(c.x - 50.0, cuff_y, 100.0, 18.0), outline, false, 2.0)


## Símbolos: gorro de la libertad (libertadores), corona (tiranos) y cadenas (El Esclavista).
static func draw_symbol(ci: CanvasItem, kind: String, c: Vector2, sc: float, col: Color) -> void:
	match kind:
		"cap":
			var pts := PackedVector2Array([
				c + Vector2(-26, 20) * sc, c + Vector2(-24, -4) * sc, c + Vector2(-12, -16) * sc,
				c + Vector2(4, -28) * sc, c + Vector2(20, -14) * sc, c + Vector2(26, 20) * sc])
			ci.draw_colored_polygon(pts, col)
			ci.draw_rect(Rect2(c + Vector2(-30, 16) * sc, Vector2(60, 9) * sc), col)
		"crown":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-30, 16) * sc, c + Vector2(-30, -16) * sc, c + Vector2(-14, 2) * sc,
				c + Vector2(0, -22) * sc, c + Vector2(14, 2) * sc, c + Vector2(30, -16) * sc,
				c + Vector2(30, 16) * sc]), col)
			ci.draw_rect(Rect2(c + Vector2(-30, 20) * sc, Vector2(60, 8) * sc), col)
			for x in [-30.0, 0.0, 30.0]:
				ci.draw_circle(c + Vector2(x, -18 if x != 0.0 else -26) * sc, 4.0 * sc, col)
		"chain":
			ci.draw_arc(c + Vector2(-14, 0) * sc, 14.0 * sc, 0.0, TAU, 28, col, 6.0 * sc)
			ci.draw_arc(c + Vector2(14, 0) * sc, 14.0 * sc, 0.0, TAU, 28, col, 6.0 * sc)
			ci.draw_rect(Rect2(c + Vector2(-6, -4) * sc, Vector2(12, 8) * sc), col)
