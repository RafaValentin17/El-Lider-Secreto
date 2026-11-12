class_name BackgroundView
extends Control
## Fondo animado: degradado nocturno con estrellas que parpadean y un halo dorado.

var stars: Array = []
var t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	for _i in 70:
		stars.append({"p": Vector2(randf(), randf()), "s": randf_range(0.6, 2.2), "v": randf_range(0.3, 1.0)})


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	# Degradado granate oscuro, casi negro en los bordes.
	var top := Color("#1a0909")
	var bot := Color("#4a1a24")
	var steps := 40
	for i in steps:
		var a := float(i) / float(steps)
		draw_rect(Rect2(0, size.y * a, size.x, size.y / float(steps) + 1.0), top.lerp(bot, a))
	draw_circle(Vector2(size.x * 0.5, size.y * 0.1), size.x * 0.6, Color(0.95, 0.75, 0.2, 0.05))
	var gold := Color(0.83, 0.68, 0.22, 0.22)
	var gold_hi := Color(0.95, 0.8, 0.35, 0.35)
	# Entramado de rombos dorados.
	var step := 72.0
	var x := -size.y
	while x < size.x + size.y:
		draw_line(Vector2(x, 0), Vector2(x + size.y, size.y), gold, 1.2)
		draw_line(Vector2(x + size.y, 0), Vector2(x, size.y), gold, 1.2)
		x += step
	# Rosetas en los cruces del entramado.
	var gy := 0.0
	while gy <= size.y:
		var gx := 0.0
		while gx <= size.x:
			draw_arc(Vector2(gx, gy), 9.0, 0.0, TAU, 14, gold_hi, 1.5)
			draw_circle(Vector2(gx, gy), 3.0, gold_hi)
			gx += step
		gy += step
	# Marco doble dorado y esquinas con volutas.
	var m := 14.0
	draw_rect(Rect2(m, m, size.x - m * 2.0, size.y - m * 2.0), Color(0.83, 0.68, 0.22, 0.45), false, 2.0)
	draw_rect(Rect2(m + 6.0, m + 6.0, size.x - (m + 6.0) * 2.0, size.y - (m + 6.0) * 2.0), Color(0.83, 0.68, 0.22, 0.25), false, 1.0)
	for corner in [Vector2(m, m), Vector2(size.x - m, m), Vector2(m, size.y - m), Vector2(size.x - m, size.y - m)]:
		draw_arc(corner, 26.0, 0.0, TAU, 24, Color(0.83, 0.68, 0.22, 0.6), 2.0)
		draw_circle(corner, 5.0, Color(0.83, 0.68, 0.22, 0.7))
	# Medallón central, muy suave, detrás del juego.
	var c := Vector2(size.x * 0.5, size.y * 0.5)
	draw_arc(c, minf(size.x, size.y) * 0.42, 0.0, TAU, 96, Color(0.83, 0.68, 0.22, 0.10), 3.0)
	draw_arc(c, minf(size.x, size.y) * 0.36, 0.0, TAU, 96, Color(0.83, 0.68, 0.22, 0.08), 2.0)
	for st in stars:
		var pos: Vector2 = st["p"] * size
		var tw := 0.5 + 0.5 * sin(t * st["v"] * 3.0 + st["s"] * 10.0)
		draw_circle(pos, st["s"], Color(1, 0.95, 0.8, 0.2 + 0.6 * tw))
