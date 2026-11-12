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
	var top := Color("#3a2a1a")
	var bot := Color("#6b4a2b")
	var steps := 40
	for i in steps:
		var a := float(i) / float(steps)
		draw_rect(Rect2(0, size.y * a, size.x, size.y / float(steps) + 1.0), top.lerp(bot, a))
	draw_circle(Vector2(size.x * 0.5, size.y * 0.12), size.x * 0.6, Color(0.95, 0.75, 0.2, 0.06))
	# Entramado victoriano sutil: diagonales doradas y rosetas en los cruces.
	var step := 64.0
	var lines_col := Color(0.85, 0.7, 0.35, 0.08)
	var x := -size.y
	while x < size.x + size.y:
		draw_line(Vector2(x, 0), Vector2(x + size.y, size.y), lines_col, 1.0)
		draw_line(Vector2(x + size.y, 0), Vector2(x, size.y), lines_col, 1.0)
		x += step
	var gy := 0.0
	while gy < size.y:
		var gx := 0.0
		while gx < size.x:
			draw_arc(Vector2(gx, gy), 7.0, 0.0, TAU, 12, Color(0.85, 0.7, 0.35, 0.10), 1.0)
			gx += step
		gy += step
	for st in stars:
		var pos: Vector2 = st["p"] * size
		var tw := 0.5 + 0.5 * sin(t * st["v"] * 3.0 + st["s"] * 10.0)
		draw_circle(pos, st["s"], Color(1, 0.95, 0.8, 0.2 + 0.6 * tw))
