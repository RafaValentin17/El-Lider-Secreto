class_name Envelope
extends Control
## Sobre con el rol dentro. Toca o desliza la tapa para abrirlo; toca la carta para girarla y desliza hacia arriba para guardarla.

const CARD_OUT := Vector2(75, 30)
const CARD_IN := Vector2(75, 200)

var role := "liberal"
var card: SwipeCard
var flap: Control
var front: Control
var state := "closed"    # closed | opening | out | closing
var shown := false
var pressing := false
var press_y := 0.0


class Front extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, h), Vector2(0, h * 0.5), Vector2(w * 0.5, h * 0.78), Vector2(w, h * 0.5), Vector2(w, h)]), Color("#e0c98a"))
		draw_circle(Vector2(w * 0.5, h * 0.7), 16.0, Color("#a3262b"))
		draw_string(ThemeDB.fallback_font, Vector2(w * 0.5 - 50, h - 12), "SECRETO", HORIZONTAL_ALIGNMENT_CENTER, 100, 12, Color("#5a3e12"))


class Flap extends Control:
	func _draw() -> void:
		draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x * 0.5, size.y)]), Color("#d4b76a"))


func _init() -> void:
	custom_minimum_size = Vector2(320, 400)


func set_role(r: String) -> void:
	role = r


func _ready() -> void:
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	card = SwipeCard.new()
	card.setup("L", false, Vector2(170, 240))
	card.position = CARD_IN
	card.visible = false
	card.tapped.connect(_on_card_tap)
	card.activated.connect(_on_card_swipe)
	add_child(card)
	front = Front.new()
	front.size = size
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(front)
	flap = Flap.new()
	flap.size = Vector2(size.x, 130.0)
	flap.pivot_offset = Vector2(size.x * 0.5, 0.0)
	flap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flap)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#f3e6c4"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#b08d3c"), false, 3.0)


## Con el sobre cerrado, un toque o un arrastre hacia arriba en la tapa lo abre.
func _gui_input(event: InputEvent) -> void:
	if state != "closed":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressing = true
			press_y = event.position.y
		elif pressing:
			pressing = false
			_open()
	elif event is InputEventMouseMotion and pressing and event.position.y - press_y < -30.0:
		pressing = false
		_open()


func _open() -> void:
	state = "opening"
	Sfx.play("open")
	var tw := create_tween()
	tw.tween_property(flap, "scale:y", 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_card_out)


func _card_out() -> void:
	state = "out"
	shown = false
	card.done = false
	card.setup("L", false, Vector2(170, 240))
	card.position = CARD_IN
	card.visible = true
	Sfx.play("swish")
	var tw := create_tween()
	tw.tween_property(card, "position", CARD_OUT, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Toque en la carta: la gira para ver el rol; otro toque la vuelve a girar boca abajo.
func _on_card_tap(_c) -> void:
	if state != "out":
		return
	Sfx.play("flip")
	if shown:
		card.flip_to("L", false)
	else:
		card.reveal_role(role)
	shown = not shown


## Deslizar la carta hacia arriba: vuelve a entrar en el sobre y el sobre se cierra.
func _on_card_swipe(_c) -> void:
	if state != "out":
		return
	state = "closing"
	var tw := create_tween()
	tw.tween_property(card, "position", CARD_IN, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_callback(_close_flap)


func _close_flap() -> void:
	card.visible = false
	card.done = false
	shown = false
	Sfx.play("close")
	var tw := create_tween()
	tw.tween_property(flap, "scale:y", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_set_closed)


func _set_closed() -> void:
	state = "closed"
