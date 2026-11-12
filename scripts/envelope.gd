class_name Envelope
extends Control
## Sobre cerrado con sello de cera: desliza para abrirlo (la solapa sube y el sello queda volteado),
## toca para voltear la carta y vuelve a deslizar para guardarla.

const TOP := 170.0
const BODY_H := 220.0
const FLAP_H := 120.0
const CARD_OUT := Vector2(65, 0)
const CARD_IN := Vector2(65, 230)
const WAX := Color("#8e1212")
const WAX_DARK := Color("#4f0a0a")
const GOLD := Color("#d4af37")

var role := "liberal"
var card: SwipeCard
var flap: Control
var hint: Label
var state := "closed"    # closed | opening | out | closing
var shown := false
var pressing := false
var press_y := 0.0


class Flap extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w * 0.5, h)]), Color("#d6b07a"))
		draw_polyline(PackedVector2Array([Vector2(0, 0), Vector2(w * 0.5, h), Vector2(w, 0)]), Color("#2b1d0e"), 3.0)
		# Sello de cera roja con un símbolo dorado (corona) en la punta de la solapa.
		var c := Vector2(w * 0.5, h * 0.66)
		draw_circle(c + Vector2(2, 3), 26.0, Color(0, 0, 0, 0.35))
		draw_circle(c, 26.0, Envelope.WAX)
		draw_arc(c, 21.0, 0.0, TAU, 32, Envelope.WAX_DARK, 2.0)
		draw_arc(c, 26.0, 0.0, TAU, 32, Envelope.WAX_DARK, 3.0)
		var g := Envelope.GOLD
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-13, 7), c + Vector2(-15, -8), c + Vector2(-6, 0), c + Vector2(0, -11),
			c + Vector2(6, 0), c + Vector2(15, -8), c + Vector2(13, 7)]), g)
		draw_rect(Rect2(c + Vector2(-13, 7), Vector2(26, 4)), g)


func _init() -> void:
	custom_minimum_size = Vector2(300, TOP + BODY_H + 70)


func set_role(r: String) -> void:
	role = r


func _ready() -> void:
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	flap = Flap.new()
	flap.position = Vector2(0, TOP)
	flap.size = Vector2(size.x, FLAP_H)
	flap.pivot_offset = Vector2(size.x * 0.5, 0.0)
	flap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flap.z_index = 1
	add_child(flap)
	card = SwipeCard.new()
	card.setup("L", false, Vector2(170, 240))
	card.position = CARD_IN
	card.visible = false
	card.z_index = -1
	card.tapped.connect(_on_card_tap)
	card.activated.connect(_on_card_swipe)
	add_child(card)
	hint = Label.new()
	hint.position = Vector2(0, TOP + BODY_H + 18.0)
	hint.size = Vector2(size.x, 36)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_color_override("font_color", Color("#f2c14e"))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	set_hint("Desliza para abrir el sobre")


func _draw() -> void:
	var body := Rect2(0, TOP, size.x, BODY_H)
	draw_rect(body, Color("#c9a46a"))
	draw_rect(body, Color("#2b1d0e"), false, 4.0)
	draw_rect(body.grow(-10.0), Color("#b8925a"), false, 2.0)


func set_hint(t: String) -> void:
	hint.text = t


## Abrir: desliza o toca el sobre cerrado.
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
	set_hint("")
	Sfx.play("open")
	# Cuando la solapa ya está plana, pasa detrás: queda por encima del sobre y la carta sale delante.
	get_tree().create_timer(0.25).timeout.connect(func(): flap.z_index = -2)
	var tw := create_tween()
	tw.tween_property(flap, "scale:y", -1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_card_out)


func _card_out() -> void:
	state = "out"
	shown = false
	card.done = false
	card.setup("L", false, Vector2(170, 240))
	card.position = Vector2(CARD_IN.x, TOP + 60.0)
	card.modulate.a = 0.0
	card.visible = true
	card.z_index = 2
	Sfx.play("swish")
	set_hint("Toca para voltear la carta")
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(card, "position", CARD_OUT, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "modulate:a", 1.0, 0.3)


## Toque en la carta: la voltea para ver el rol; otro toque la vuelve a dejar boca abajo.
func _on_card_tap(_c) -> void:
	if state != "out":
		return
	Sfx.play("flip")
	if shown:
		card.flip_to("L", false)
		set_hint("Toca para voltear la carta")
	else:
		card.reveal_role(role)
		set_hint("Vuelve a deslizar para guardar la carta")
	shown = not shown


## Deslizar la carta hacia arriba: vuelve al sobre y el sobre se cierra.
func _on_card_swipe(_c) -> void:
	if state != "out":
		return
	state = "closing"
	set_hint("")
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(card, "position", Vector2(CARD_IN.x, TOP + 60.0), 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(card, "modulate:a", 0.0, 0.45)
	tw.chain().tween_callback(_close_flap)


func _close_flap() -> void:
	card.visible = false
	card.z_index = -1
	card.done = false
	shown = false
	Sfx.play("close")
	var tw := create_tween()
	tw.tween_property(flap, "scale:y", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_set_closed)


func _set_closed() -> void:
	state = "closed"
	flap.z_index = 1
	set_hint("Desliza para abrir el sobre")
