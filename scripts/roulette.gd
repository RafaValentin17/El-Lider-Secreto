class_name Roulette
extends Control
## Ruleta victoriana: un sector de color por jugador. Gira y se detiene en el elegido, bajo el puntero.

const COLORS := [
	Color("#7a1f2b"), Color("#1f3a5f"), Color("#24513a"), Color("#4b2a5c"), Color("#8a5a1f"),
	Color("#1d5a5a"), Color("#5c1a1a"), Color("#3d4a5c"), Color("#8c6b1f"), Color("#2b2b2b"),
]
const GOLD := Color("#d4af37")
const CREAM := Color("#f5f0e1")
const INK := Color("#1a1208")

var names: Array = []
var rot := 0.0


func set_players(n: Array) -> void:
	names = n
	custom_minimum_size = Vector2(340, 340)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _radius() -> float:
	return minf(size.x, size.y) * 0.5 - 14.0


func _draw() -> void:
	var n := names.size()
	if n == 0:
		return
	var c := size * 0.5
	var R := _radius()
	var step := TAU / float(n)
	var font := ThemeDB.fallback_font
	# Aro exterior de madera oscura con relieve.
	draw_circle(c, R + 12.0, INK)
	draw_arc(c, R + 12.0, 0.0, TAU, 96, GOLD, 3.0)
	for i in n:
		var a0 := rot + i * step
		var a1 := a0 + step
		var pts := PackedVector2Array([c])
		var seg := 14
		for k in seg + 1:
			var a := lerpf(a0, a1, float(k) / float(seg))
			pts.append(c + Vector2(cos(a), sin(a)) * R)
		draw_colored_polygon(pts, COLORS[i % COLORS.size()])
		# Filete dorado entre sectores.
		draw_line(c, c + Vector2(cos(a0), sin(a0)) * R, GOLD, 2.0)
		# Nombre a lo largo del radio, en el centro del sector.
		var mid := a0 + step * 0.5
		draw_set_transform(c, mid, Vector2.ONE)
		draw_string(font, Vector2(R * 0.22, 7.0), String(names[i]), HORIZONTAL_ALIGNMENT_LEFT, R * 0.7, 20, CREAM)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Adorno: pequeño diamante dorado en el borde de cada sector.
		var d := c + Vector2(cos(a0), sin(a0)) * (R - 6.0)
		draw_circle(d, 4.0, GOLD)
	draw_arc(c, R, 0.0, TAU, 96, GOLD, 4.0)
	draw_arc(c, R * 0.92, 0.0, TAU, 96, GOLD, 1.5)
	# Centro: medallón.
	draw_circle(c, R * 0.14, INK)
	draw_arc(c, R * 0.14, 0.0, TAU, 32, GOLD, 3.0)
	draw_circle(c, R * 0.05, GOLD)
	# Puntero dorado arriba.
	var tip := Vector2(c.x, c.y - R - 2.0)
	draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-16, -28), tip + Vector2(16, -28)]), GOLD)
	draw_polyline(PackedVector2Array([tip, tip + Vector2(-16, -28), tip + Vector2(16, -28), tip]), INK, 2.0)


## Gira hasta que el sector elegido quede bajo el puntero y luego llama a done.
func spin(final_idx: int, done: Callable) -> void:
	var n := names.size()
	if n == 0:
		done.call()
		return
	var step := TAU / float(n)
	var center_angle := (final_idx + 0.5) * step
	var target := -PI * 0.5 - center_angle + 6.0 * TAU
	rot = 0.0
	var tw := create_tween()
	tw.tween_property(self, "rot", target, 4.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(done)
	# Un clic por cada sector que pasa bajo el puntero, para el sonido.
	var ticks := 6 * n
	for k in range(ticks):
		var t := 4.5 * (1.0 - pow(1.0 - float(k) / float(ticks), 3.0))
		get_tree().create_timer(t).timeout.connect(func(): Sfx.play("tap"))
	queue_redraw()
