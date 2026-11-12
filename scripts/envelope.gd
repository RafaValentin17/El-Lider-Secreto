class_name Envelope
extends Control
## Sobre cerrado. Un toque en la solapa la levanta y asoma la carta. Tocar la carta la gira;
## deslizarla hacia arriba la guarda y el sobre se vuelve a cerrar.

const W := 300.0
const H := 230.0
const TOP := 120.0                          # espacio por encima del sobre para que la carta suba
const CARD_SZ := Vector2(150, 210)
const PEEK := Vector2(75, 110)              # carta asomando por la boca del sobre
const UP := Vector2(75, -100)               # carta levantada para verla entera
const INSIDE := Vector2(75, 260)            # carta dentro, oculta tras la parte delantera

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
			Vector2(0, h), Vector2(0, h * 0.5), Vector2(w * 0.5, h * 0.78), Vector2(w, h * 0.5), Vector2(w, h)]), Color("#b98a4e"))
		draw_polyline(PackedVector2Array([Vector2(0, h * 0.5), Vector2(w * 0.5, h * 0.78), Vector2(w, h * 0.5)]), Color("#2b1d0e"), 4.0)
		draw_circle(Vector2(w * 0.5, h * 0.7), 16.0, Color("#a3262b"))
		draw_string(ThemeDB.fallback_font, Vector2(w * 0.5 - 50, h - 12), "SECRETO", HORIZONTAL_ALIGNMENT_CENTER, 100, 12, Color("#2b1d0e"))


class Flap extends Control:
	func _draw() -> void:
		var pts := PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x * 0.5, size.y)])
		draw_colored_polygon(pts, Color("#d6a86a"))
		draw_polyline(PackedVector2Array([Vector2(0, 0), Vector2(size.x * 0.5, size.y), Vector2(size.x, 0)]), Color("#2b1d0e"), 4.0)


func _init() -> void:
	custom_minimum_size = Vector2(W, TOP + H)


func set_role(r: String) -> void:
	role = r


func _ready() -> void:
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	card = SwipeCard.new()
	card.setup("L", false, CARD_SZ)
	card.position = INSIDE
	card.visible = false
	card.tapped.connect(_on_card_tap)
	card.activated.connect(_on_card_swipe)
	add_child(card)
	front = Front.new()
	front.position = Vector2(0, TOP)
	front.size = Vector2(W, H)
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(front)
	flap = Flap.new()
	flap.position = Vector2(0, TOP)
	flap.size = Vector2(W, 110.0)
	flap.pivot_offset = Vector2(W * 0.5, 0.0)
	flap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flap)


func _draw() -> void:
	draw_rect(Rect2(0, TOP, W, H), Color("#c9a46a"))
	draw_rect(Rect2(0, TOP, W, H), Color("#2b1d0e"), false, 4.0)


## Con el sobre cerrado, un toque o un arrastre hacia abajo sobre la solapa lo abre.
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
	elif event is InputEventMouseMotion and pressing and event.position.y - press_y > 20.0:
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
	card.setup("L", false, CARD_SZ)
	card.position = INSIDE
	card.visible = true
	Sfx.play("swish")
	var tw := create_tween()
	tw.tween_property(card, "position", PEEK, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Toque en la carta: se levanta entera y se gira para ver el rol; otro toque la vuelve a girar y la baja.
func _on_card_tap(_c) -> void:
	if state != "out":
		return
	Sfx.play("flip")
	var tw := create_tween()
	if shown:
		card.flip_to("L", false)
		tw.tween_property(card, "position", PEEK, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		card.reveal_role(role)
		tw.tween_property(card, "position", UP, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	shown = not shown


## Deslizar la carta hacia arriba: vuelve a entrar en el sobre y el sobre se cierra.
func _on_card_swipe(_c) -> void:
	if state != "out":
		return
	state = "closing"
	var tw := create_tween()
	tw.tween_property(card, "position", INSIDE, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
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
