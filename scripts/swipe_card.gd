class_name SwipeCard
extends PolicyCard
## Carta que se desliza hacia arriba para ejecutar una acción (votar, descartar, guardar). Un toque emite "tapped".

signal activated(card)
signal tapped(card)

const THRESHOLD := 110.0

var dragging := false
var done := false
var press_pos := Vector2.ZERO
var home := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			press_pos = get_global_mouse_position()
			home = position
		elif dragging:
			dragging = false
			var dy: float = get_global_mouse_position().y - press_pos.y
			if dy < -THRESHOLD:
				done = true
				activated.emit(self)
			else:
				if absf(dy) < 8.0:
					tapped.emit(self)
				var tw := create_tween()
				tw.tween_property(self, "position", home, 0.25).set_trans(Tween.TRANS_BACK)
	elif event is InputEventMouseMotion and dragging:
		var dy2: float = get_global_mouse_position().y - press_pos.y
		position = home + Vector2(0, minf(dy2, 0.0) * 0.9)


## La carta sale hacia arriba y se desvanece (al ejecutar la acción).
func fly_away() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 420.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
