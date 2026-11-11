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
	var top := Color("#0b1020")
	var bot := Color("#2a1030")
	var steps := 40
	for i in steps:
		var a := float(i) / float(steps)
		draw_rect(Rect2(0, size.y * a, size.x, size.y / float(steps) + 1.0), top.lerp(bot, a))
	draw_circle(Vector2(size.x * 0.5, size.y * 0.12), size.x * 0.6, Color(0.95, 0.75, 0.2, 0.06))
	for st in stars:
		var pos: Vector2 = st["p"] * size
		var tw := 0.5 + 0.5 * sin(t * st["v"] * 3.0 + st["s"] * 10.0)
		draw_circle(pos, st["s"], Color(1, 0.95, 0.8, 0.2 + 0.6 * tw))
