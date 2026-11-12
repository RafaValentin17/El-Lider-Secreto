extends Control
## Secret El Esclavista: sobres, cartas deslizables, tablero y pilas. Un móvil que pasa de mano entre jugadores.

const CREAM := Color("#f5f0e1")
const GOLD := Color("#f2c14e")
const MUTED := Color("#9fb3c8")
const BLUE := Color("#2f6f8f")
const RED := Color("#b5452b")
const DARK := Color("#3b0d0d")
const NAVY := Color("#33413a")
const GREEN := Color("#4f7d3a")
const GREY := Color("#4a4a5e")
const INK := Color("#2b1d0e")
const TXT := 1.3  # factor de tamaño para textos legibles en móvil

var scroll: ScrollContainer
var margin: MarginContainer
var box: VBoxContainer
var cur: Control
var stack: Array = []
var overlay: Control
var fas_view: BoardView
var lib_view: BoardView
var game: GameLogic
var player_count := 5
var saved_names: Array = []
var name_edits: Array = []
var vote_queue: Array = []
var vote_map: Dictionary = {}
var last_draw := 0
var last_discard := 0
var pending_pulse: Array = []
var setup_names: Array = []
var sound_btn: Button
var role_btn: Button
var center_screen := false
var rules_page := 0
var net: Net
var online_url := "wss://coronareal-server.onrender.com"
var online_name := ""
var online_code := ""
var online_create := true
var online_last: Dictionary = {}
var online_role_seen := false
var online_role_pending := false
var online_spun := false
var online_url_edit: LineEdit
var online_name_edit: LineEdit
var online_code_edit: LineEdit


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(BackgroundView.new())
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	cur = box
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	sound_btn = Button.new()
	sound_btn.add_theme_font_size_override("font_size", 18)
	sound_btn.add_theme_color_override("font_color", CREAM)
	sound_btn.add_theme_stylebox_override("normal", _sb(Color("#3b2a1a")))
	sound_btn.add_theme_stylebox_override("hover", _sb(Color("#4d3822")))
	sound_btn.add_theme_stylebox_override("pressed", _sb(Color("#2a1d10")))
	sound_btn.anchor_left = 1.0
	sound_btn.anchor_right = 1.0
	sound_btn.offset_left = -170
	sound_btn.offset_right = -10
	sound_btn.offset_top = 10
	sound_btn.offset_bottom = 56
	sound_btn.pressed.connect(_toggle_sound)
	add_child(sound_btn)
	_update_sound_btn()
	role_btn = Button.new()
	role_btn.text = "Mi rol"
	role_btn.visible = false
	role_btn.add_theme_font_size_override("font_size", 18)
	role_btn.add_theme_color_override("font_color", CREAM)
	role_btn.add_theme_stylebox_override("normal", _sb(Color("#3b2a1a")))
	role_btn.add_theme_stylebox_override("hover", _sb(Color("#4d3822")))
	role_btn.add_theme_stylebox_override("pressed", _sb(Color("#2a1d10")))
	role_btn.anchor_left = 0.0
	role_btn.anchor_right = 0.0
	role_btn.offset_left = 10
	role_btn.offset_right = 160
	role_btn.offset_top = 10
	role_btn.offset_bottom = 56
	role_btn.pressed.connect(_open_role)
	add_child(role_btn)
	net = Net.new()
	net.name = "Net"
	add_child(net)
	net.state_changed.connect(_on_online_state)
	net.error_msg.connect(_toast)
	net.connected_ok.connect(_on_connected)
	net.connect_failed.connect(_on_connect_failed)
	var port := OS.get_environment("PORT")
	if OS.get_cmdline_user_args().has("--server"):
		net.start_server(int(port) if port != "" else 8910)
	show_menu()


# ---------- ayudas de interfaz ----------

func _clear(center: bool = false) -> void:
	center_screen = center
	if role_btn != null:
		role_btn.visible = false
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	cur = box
	stack = []


func _sb(col: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(14)
	s.set_border_width_all(4)
	s.border_color = INK
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 4
	s.shadow_offset = Vector2(3, 5)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


func _begin_panel(col: Color) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(col))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 8)
	p.add_child(inner)
	cur.add_child(p)
	stack.append(cur)
	cur = inner


func _end_panel() -> void:
	cur = stack.pop_back()


func _lbl(text: String, size: int = 22, col: Color = CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", int(size * TXT))
	l.add_theme_color_override("font_color", col)
	cur.add_child(l)
	return l


func _btn(text: String, cb: Callable, col: Color = Color("#2c4f7c")) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 84)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", int(26 * TXT))
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_stylebox_override("normal", _sb(col))
	b.add_theme_stylebox_override("hover", _sb(col.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _sb(col.darkened(0.25)))
	b.add_theme_stylebox_override("focus", _sb(col))
	b.pressed.connect(Sfx.play.bind("tap"))
	b.pressed.connect(cb)
	cur.add_child(b)
	return b


## Cartas boca arriba en fila, sin acción (para la ojeada).
func _cards_row(cards: Array) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	cur.add_child(row)
	for idx in cards.size():
		var card := PolicyCard.new()
		card.setup(cards[idx], true)
		row.add_child(card)
		card.pop_in(0.12 * idx)


## Zona donde las cartas se deslizan hacia arriba para ejecutar una acción.
func _stage(cards: Array, cb: Callable, hint: String) -> void:
	_lbl(hint, 18, GOLD)
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(0, 280)
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cur.add_child(stage)
	var n := cards.size()
	for idx in n:
		var c: SwipeCard = cards[idx]
		stage.add_child(c)
		_place(c, idx, n)
		c.activated.connect(_on_swiped.bind(idx, cb))


func _place(c: Control, idx: int, n: int) -> void:
	var frac: float = (idx + 0.5) / float(n)
	var w: float = c.custom_minimum_size.x
	var h: float = c.custom_minimum_size.y
	c.anchor_left = frac
	c.anchor_right = frac
	c.anchor_top = 0.0
	c.anchor_bottom = 0.0
	c.offset_left = -w * 0.5
	c.offset_right = w * 0.5
	c.offset_top = 20.0
	c.offset_bottom = 20.0 + h


func _on_swiped(card: SwipeCard, idx: int, cb: Callable) -> void:
	for c in card.get_parent().get_children():
		if c is SwipeCard:
			c.done = true
	Sfx.play("swish")
	card.reparent(overlay, true)
	card.fly_away()
	get_tree().create_timer(0.4).timeout.connect(card.queue_free)
	get_tree().create_timer(0.35).timeout.connect(cb.bind(idx))


## Las cartas llegan desde la pila de robar y se giran al llegar.
func _animate_draw(cards: Array, kinds: Array) -> void:
	await get_tree().process_frame
	for idx in cards.size():
		var c: SwipeCard = cards[idx]
		if not is_instance_valid(c):
			return
		var home := c.position
		c.position = home + Vector2(0, 460)
		var tw := c.create_tween()
		tw.tween_interval(0.2 * idx)
		tw.tween_property(c, "position", home, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_callback(_flip_card.bind(c, kinds[idx]))


func _flip_card(c: PolicyCard, k: String) -> void:
	Sfx.play("draw")
	c.flip_to(k, true)


func _pname(i: int) -> String:
	return String(game.players[i]["name"])


func _pname_or(i: int) -> String:
	return _pname(i) if i >= 0 else "—"


func _short(t: String, empty: String) -> String:
	if t == "":
		return "(" + empty + ")"
	return t if t.length() <= 16 else t.substr(0, 15) + "…"


func _join(arr: Array) -> String:
	var s := ""
	for x in arr:
		s += (", " if s != "" else "") + str(x)
	return s


## Pantalla intermedia: el siguiente jugador toma el móvil.
func _pass(i: int, next: Callable) -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Pasa el móvil a", 26, MUTED)
	_lbl(_pname(i), 44, GOLD)
	_lbl("Que nadie más vea la pantalla.", 18, MUTED)
	_end_panel()
	_btn("Soy %s, continuar" % _pname(i), next, GREEN)


# ---------- menú, reglas y configuración ----------

func show_menu() -> void:
	_clear(true)
	_begin_panel(DARK)
	_lbl(Txt.TITLE, 42, GOLD)
	_lbl("Juego de deducción política para 5 a 10 jugadores. Se juega pasando el móvil.", 18, CREAM)
	_end_panel()
	_btn("Nueva partida", show_setup, GREEN)
	_btn("Jugar online", show_online_menu, Color("#6a3d9a"))
	_btn("Reglas", show_rules)


func show_rules(page: int = 0) -> void:
	_clear()
	var secs: Array = Txt.RULE_SECTIONS
	rules_page = clampi(page, 0, secs.size() - 1)
	var sec: Dictionary = secs[rules_page]
	_begin_panel(Color(sec["color"]))
	_lbl("Reglas %d de %d" % [rules_page + 1, secs.size()], 16, CREAM)
	_lbl(sec["title"], 28, GOLD)
	for line in sec["lines"]:
		_lbl("• " + line, 19)
	_end_panel()
	if sec.has("example"):
		_begin_panel(Color("#1e3a2b"))
		_lbl("Ejemplo", 16, GOLD)
		_lbl(sec["example"], 18, CREAM)
		_end_panel()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	cur.add_child(row)
	_nav_btn(row, "<", show_rules.bind(rules_page - 1), rules_page > 0)
	_nav_btn(row, "Volver", show_menu, true)
	_nav_btn(row, ">", show_rules.bind(rules_page + 1), rules_page < secs.size() - 1)


func _nav_btn(row: HBoxContainer, text: String, cb: Callable, enabled: bool) -> void:
	var b := Button.new()
	b.text = text
	b.disabled = not enabled
	b.custom_minimum_size = Vector2(0, 84)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", int(34 * TXT) if text.length() == 1 else int(24 * TXT))
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_disabled_color", MUTED)
	b.add_theme_stylebox_override("normal", _sb(Color("#2f6f8f")))
	b.add_theme_stylebox_override("hover", _sb(Color("#3a82a6")))
	b.add_theme_stylebox_override("pressed", _sb(Color("#245a72")))
	b.add_theme_stylebox_override("disabled", _sb(Color("#4a4a4a")))
	b.pressed.connect(Sfx.play.bind("tap"))
	b.pressed.connect(cb)
	row.add_child(b)


func show_setup() -> void:
	_clear(true)
	_lbl("Nueva partida", 34, GOLD)
	_lbl("¿Cuántos jugadores?", 22, CREAM)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	cur.add_child(grid)
	for n in range(5, 11):
		var b := Button.new()
		b.text = str(n)
		b.custom_minimum_size = Vector2(0, 110)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", int(40 * TXT))
		b.add_theme_color_override("font_color", CREAM)
		var col: Color = GREEN if n == player_count else Color("#2f6f8f")
		b.add_theme_stylebox_override("normal", _sb(col))
		b.add_theme_stylebox_override("hover", _sb(col.lightened(0.15)))
		b.add_theme_stylebox_override("pressed", _sb(col.darkened(0.25)))
		b.pressed.connect(Sfx.play.bind("tap"))
		b.pressed.connect(_set_count.bind(n))
		grid.add_child(b)
	_lbl("Nombres de los jugadores", 20, CREAM)
	while setup_names.size() < 10:
		setup_names.append("")
	for i in player_count:
		if OS.has_feature("web"):
			_btn("%d. %s" % [i + 1, _name_or_default(i)], _ask_name.bind(i), Color("#33465f"))
		else:
			var e := LineEdit.new()
			e.placeholder_text = "Jugador %d" % (i + 1)
			e.text = setup_names[i]
			e.custom_minimum_size = Vector2(0, 70)
			e.add_theme_font_size_override("font_size", int(22 * TXT))
			var idx := i
			e.text_changed.connect(func(t: String): setup_names[idx] = t)
			cur.add_child(e)
	_btn("Empezar", _start_game, GREEN)
	_btn("Volver", show_menu)


func _set_count(n: int) -> void:
	player_count = n
	show_setup()


func _name_or_default(i: int) -> String:
	return String(setup_names[i]) if String(setup_names[i]) != "" else "Jugador %d" % (i + 1)


## Abre el cuadro nativo del navegador para escribir el nombre (funciona en móviles).
func _ask_name(i: int) -> void:
	var res = JavaScriptBridge.eval("prompt(%s, %s)" % [JSON.stringify("Nombre del jugador %d" % (i + 1)), JSON.stringify(String(setup_names[i]))])
	if res != null:
		setup_names[i] = String(res).strip_edges()
	show_setup()


func _start_game() -> void:
	var names: Array = []
	for i in player_count:
		var t: String = String(setup_names[i]).strip_edges()
		if t == "":
			t = "Jugador %d" % (i + 1)
		names.append(t)
	game = GameLogic.new()
	game.setup(names)
	last_draw = game.draw_pile.size()
	last_discard = 0
	pending_pulse = []
	_reveal_roles(0)


# ---------- consulta de rol desde el tablero ----------

func _open_role() -> void:
	if not online_last.is_empty():
		_show_online_role(online_last)
		return
	_show_role_pick()


func _show_role_pick() -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("¿Quién eres?", 26, GOLD)
	_lbl("Elige tu nombre para abrir tu sobre.", 17, MUTED)
	_end_panel()
	for i in game.players.size():
		_btn(_pname(i), func(): _show_role_again(i), DARK)
	_btn("Volver al tablero", show_board, GREY)


func _show_role_again(i: int) -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Tu sobre secreto", 26, GOLD)
	_lbl("Solo tú puedes ver tu rol.", 17, MUTED)
	_end_panel()
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 90)
	cur.add_child(gap)
	var center := CenterContainer.new()
	cur.add_child(center)
	var env := Envelope.new()
	env.set_role(game.players[i]["role"])
	center.add_child(env)
	_btn("Volver al tablero", show_board, GREY)


# ---------- sobres de rol ----------

func _reveal_roles(i: int) -> void:
	if i >= game.players.size():
		_reveal_team(0)
		return
	_pass(i, func(): _show_role(i))


func _show_role(i: int) -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Tu sobre secreto", 26, GOLD)
	_lbl("Solo tú puedes ver tu rol.", 17, MUTED)
	_end_panel()
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 90)
	cur.add_child(gap)
	var center := CenterContainer.new()
	cur.add_child(center)
	var env := Envelope.new()
	env.set_role(game.players[i]["role"])
	center.add_child(env)
	_btn("Ocultar y seguir", func(): _reveal_roles(i + 1), GREY)


func _team_members() -> Array:
	var res: Array = []
	for i in game.players.size():
		if game.players[i]["role"] != GameLogic.LIBERTADOR:
			res.append(i)
	return res


func _names_with(role: String, exclude: int) -> String:
	var out: Array = []
	for i in game.players.size():
		if i != exclude and game.players[i]["role"] == role:
			out.append(_pname(i))
	return _join(out) if out.size() > 0 else "nadie"


func _reveal_team(k: int) -> void:
	var team := _team_members()
	if k >= team.size():
		_show_draw_president()
		return
	var i: int = team[k]
	_pass(i, func(): _show_team(i, k))


func _show_team(i: int, k: int) -> void:
	_clear(true)
	var role: String = game.players[i]["role"]
	var n: int = game.players.size()
	_begin_panel(DARK if role == "hitler" else RED)
	_lbl("Conoces a tu equipo", 24, GOLD)
	if role == "fascist":
		_lbl("Otros tiranos: %s." % _names_with(GameLogic.FASCIST, i), 20)
		_lbl("El Esclavista: %s." % _names_with(GameLogic.HITLER, i), 20)
	elif n <= 6:
		_lbl("Eres El Esclavista. Tiranos: %s." % _names_with(GameLogic.FASCIST, i), 20)
	else:
		_lbl("Eres El Esclavista. No conoces a ningún fascista.", 20)
	_end_panel()
	_btn("Ocultar y seguir", func(): _reveal_team(k + 1), GREY)


# ---------- tablero principal ----------

func show_board() -> void:
	_clear()
	if game.phase == "over":
		show_end()
		return

	role_btn.visible = true
	var fas_n: int = game.enacted_f
	var lib_n: int = game.enacted_l
	var fly: Array = pending_pulse
	if fly.size() == 2:
		if fly[0] == "F":
			fas_n = fly[1]
		else:
			lib_n = fly[1]
	fas_view = BoardView.new()
	fas_view.set_board("fascist", fas_n, game.power_list(), 0)
	cur.add_child(fas_view)
	lib_view = BoardView.new()
	lib_view.set_board("liberal", lib_n, [], game.tracker)
	cur.add_child(lib_view)
	var ft := FailTrack.new()
	ft.set_tracker(game.tracker)
	cur.add_child(ft)
	pending_pulse = []
	if fly.size() == 2:
		_fly_enacted(fly[0], fly[1])

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	cur.add_child(row)
	var dp := PileView.new()
	row.add_child(dp)
	dp.count = last_draw
	dp.set_pile(game.draw_pile.size(), Txt.DRAW)
	var dc := PileView.new()
	row.add_child(dc)
	dc.count = last_discard
	dc.set_pile(game.discard_pile.size(), Txt.DISCARD)
	last_draw = game.draw_pile.size()
	last_discard = game.discard_pile.size()

	_begin_panel(NAVY)
	_lbl("%s: %s     %s: %s" % [Txt.PRES, _pname_or(game.president), Txt.CHAN, _pname_or(game.chancellor)], 20, GOLD)
	_lbl(game.last_event, 17, MUTED)
	_end_panel()

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	cur.add_child(grid)
	for i in game.players.size():
		var alive: bool = game.players[i]["alive"]
		var panel := PanelContainer.new()
		var sb := _sb(Color("#263754") if alive else Color("#353535"))
		if i == game.president or i == game.chancellor:
			sb.set_border_width_all(4)
			sb.border_color = GOLD
		panel.add_theme_stylebox_override("panel", sb)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tags: Array = []
		if i == game.president:
			tags.append(Txt.PRES)
		if i == game.chancellor:
			tags.append(Txt.CHAN)
		if not alive:
			tags.append("eliminado")
		var t := Label.new()
		t.text = _pname(i) + ("\n" + _join(tags) if tags.size() > 0 else "")
		t.add_theme_font_size_override("font_size", int(18 * TXT))
		t.add_theme_color_override("font_color", CREAM if alive else MUTED)
		panel.add_child(t)
		grid.add_child(panel)

	match game.phase:
		"nominate":
			_lbl("El %s propone un %s:" % [Txt.PRES, Txt.CHAN], 22, GOLD)
			for i in game.eligible_chancellors():
				_btn(_pname(i), _nominate.bind(i), Color("#2c4f7c"))
		"vote":
			_btn("Iniciar votación secreta", _begin_vote, GREEN)
		"discard_pres":
			_btn("Continuar (%s, en privado)" % Txt.PRES, func(): _pass(game.president, _show_discard_pres), GREEN)
		"discard_chan":
			_btn("Continuar (%s, en privado)" % Txt.CHAN, func(): _pass(game.chancellor, _show_chancellor), GREEN)
		"veto_wait":
			_btn("Continuar (%s, en privado)" % Txt.PRES, func(): _pass(game.president, _show_veto), GREEN)
		"exec":
			_btn("Continuar (poder del %s)" % Txt.PRES, func(): _pass(game.president, _show_exec), GREEN)


## La política promulgada vuela desde el centro hasta su casilla del tablero.
func _fly_enacted(kind: String, idx: int) -> void:
	await get_tree().process_frame
	var board: BoardView = fas_view if kind == "F" else lib_view
	if board == null or not is_instance_valid(board):
		return
	var card := PolicyCard.new()
	card.setup(kind, true, Vector2(90, 126))
	overlay.add_child(card)
	card.global_position = get_viewport().get_visible_rect().size * 0.5 - card.size * 0.5
	var target: Vector2 = board.global_position + board.slot_pos(idx) - card.size * 0.5
	var tw := card.create_tween()
	tw.tween_property(card, "global_position", target, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(_land.bind(board, card, idx))


func _land(board: BoardView, card: PolicyCard, idx: int) -> void:
	card.queue_free()
	Sfx.play("enact")
	if is_instance_valid(board):
		board.set_enacted(idx + 1)
		board.pulse_slot(idx)


func _nominate(i: int) -> void:
	game.nominate(i)
	show_board()


# ---------- votación ----------

func _begin_vote() -> void:
	vote_queue = game.alive_indices()
	vote_map = {}
	_vote_step(0)


func _vote_step(k: int) -> void:
	if k >= vote_queue.size():
		_show_vote_result()
		return
	var i: int = vote_queue[k]
	_pass(i, func(): _show_vote_card(i, k))


func _show_vote_card(i: int, k: int) -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Voto secreto", 26, MUTED)
	_lbl("%s: %s" % [Txt.PRES, _pname(game.president)], 20)
	_lbl("%s propuesto: %s" % [Txt.CHAN, _pname(game.nominee)], 24, GOLD)
	_end_panel()
	var ja := SwipeCard.new()
	ja.setup_thumb(true, Vector2(150, 200))
	var nein := SwipeCard.new()
	nein.setup_thumb(false, Vector2(150, 200))
	_stage([ja, nein], _vote_pick.bind(i, k), "Desliza hacia arriba la carta de tu voto")


func _vote_pick(idx: int, i: int, k: int) -> void:
	Sfx.play("vote")
	_record_vote(i, idx == 0, k)


func _record_vote(i: int, v: bool, k: int) -> void:
	vote_map[i] = v
	_vote_step(k + 1)


func _show_vote_result() -> void:
	_clear()
	var passed: bool = game.resolve_vote(vote_map)
	Sfx.play("vote" if passed else "fail")
	_begin_panel(NAVY)
	_lbl("Resultado de la votación", 28, GOLD)
	var yes := 0
	for i in vote_queue:
		if vote_map[i]:
			yes += 1
	_lbl("%s: %d    %s: %d" % [Txt.JA, yes, Txt.NEIN, vote_queue.size() - yes], 24, GOLD)
	_lbl("El voto de cada jugador es secreto.", 16, MUTED)
	_lbl(game.last_event, 18, MUTED)
	_end_panel()
	_btn("Continuar", show_board, GREY)


# ---------- legislación ----------

func _show_discard_pres() -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Tus 3 políticas (en secreto)", 24, GOLD)
	_lbl("Las cartas llegan desde la pila de robar.", 17, MUTED)
	_end_panel()
	var cards: Array = []
	for c in game.hand:
		var sc := SwipeCard.new()
		sc.setup(c, false, Vector2(130, 190))
		cards.append(sc)
	_stage(cards, _discard_pres, "Desliza hacia arriba la que quieras descartar")
	_animate_draw(cards, game.hand)


func _discard_pres(idx: int) -> void:
	game.president_discard(idx)
	_pass(game.chancellor, _show_chancellor)


func _show_chancellor() -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Tus 2 políticas (en secreto)", 24, GOLD)
	_lbl("Promulga una. La otra se descarta en secreto.", 17, MUTED)
	_end_panel()
	var cards: Array = []
	for c in game.hand:
		var sc := SwipeCard.new()
		sc.setup(c, false, Vector2(140, 200))
		cards.append(sc)
	_stage(cards, _chancellor_enact, "Desliza hacia arriba la que quieras promulgar")
	_animate_draw(cards, game.hand)
	if game.can_request_veto():
		_btn("Proponer veto", _request_veto, RED)


func _chancellor_enact(idx: int) -> void:
	var card: String = game.hand[idx]
	game.chancellor_enact(idx)
	if card == "F":
		pending_pulse = ["F", game.enacted_f - 1]
	else:
		pending_pulse = ["L", game.enacted_l - 1]
	show_board()


func _request_veto() -> void:
	game.request_veto()
	_pass(game.president, _show_veto)


func _show_veto() -> void:
	_clear()
	_begin_panel(NAVY)
	_lbl("El %s propone un veto (en secreto)" % Txt.CHAN, 24, GOLD)
	_lbl("¿Aceptas descartar ambas políticas?", 20)
	_end_panel()
	_btn("Aceptar veto", _veto_answer.bind(true), GREEN)
	_btn("Rechazar veto", _veto_answer.bind(false), RED)


func _veto_answer(accept: bool) -> void:
	game.veto_answer(accept)
	if game.phase == "discard_chan":
		_pass(game.chancellor, _show_chancellor)
	else:
		show_board()


# ---------- poderes del presidente ----------

func _show_exec() -> void:
	_clear()
	match game.pending_power:
		"peek":
			_begin_panel(NAVY)
			_lbl("Ojeada a políticas (en secreto): las 3 siguientes, de arriba abajo", 22, GOLD)
			_end_panel()
			_cards_row(game.peek_top())
			_btn("Ocultar y continuar", _end_power, GREY)
		"investigate":
			_begin_panel(NAVY)
			_lbl("Investigar lealtad: elige a quién auditar (en secreto).", 22, GOLD)
			_end_panel()
			for i in game.investigable_indices():
				_btn(_pname(i), _investigate.bind(i), Color("#2c4f7c"))
		"special":
			_begin_panel(NAVY)
			_lbl("Llamada a elecciones extraordinarias: elige al siguiente %s." % Txt.PRES, 22, GOLD)
			_end_panel()
			for i in game.alive_indices():
				if i != game.president:
					_btn(_pname(i), _special.bind(i), Color("#2c4f7c"))
		"execute":
			_begin_panel(DARK)
			_lbl("Ejecución: elige a quién eliminar. No se revela su rol.", 22, GOLD)
			_end_panel()
			for i in game.alive_indices():
				if i != game.president:
					_btn(_pname(i), _execute.bind(i), RED)
		_:
			_end_power()


func _investigate(i: int) -> void:
	var party := game.investigate(i)
	_clear()
	_begin_panel(BLUE if party == "liberal" else RED)
	_lbl("Investigación (en secreto)", 24, MUTED)
	_lbl("%s pertenece a: %s" % [_pname(i), Txt.LIB if party == "liberal" else Txt.FAS], 30, GOLD)
	_end_panel()
	_btn("Ocultar y continuar", _end_power, GREY)


func _special(i: int) -> void:
	game.exec_special(i)
	show_board()


func _execute(i: int) -> void:
	game.exec_kill(i)
	show_board()


func _end_power() -> void:
	game.end_power()
	show_board()


# ---------- fin de partida ----------

func show_end() -> void:
	_clear()
	var lib_win := game.winner == "liberal"
	_begin_panel(BLUE if lib_win else RED)
	_lbl("Ganan los Libertadores" if lib_win else "Ganan los Tiranos", 36, GOLD)
	_lbl(game.win_reason, 18)
	_end_panel()
	_lbl("Roles de la partida", 22, GOLD)
	for i in game.players.size():
		var r: String = game.players[i]["role"]
		_begin_panel(BLUE if r == "liberal" else (RED if r == "fascist" else DARK))
		_lbl("%s: %s" % [_pname(i), Txt.ROLE_NAME[r]], 20)
		_end_panel()
	_btn("Nueva partida", show_setup, GREEN)
	_btn("Menú principal", show_menu, GREY)


# ---------- juego en red ----------

func _toast(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", GOLD)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _sb(DARK))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	p.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	p.offset_left = 20
	p.offset_right = -20
	p.offset_top = -170
	p.offset_bottom = -90
	overlay.add_child(p)
	get_tree().create_timer(2.8).timeout.connect(p.queue_free)


func _field(text: String, ph: String) -> LineEdit:
	var e := LineEdit.new()
	e.text = text
	e.placeholder_text = ph
	e.custom_minimum_size = Vector2(0, 70)
	e.add_theme_font_size_override("font_size", 20)
	cur.add_child(e)
	return e


func _oname(names: Array, i: int) -> String:
	return String(names[i]) if i >= 0 and i < names.size() else "—"


func _count_true(arr: Array) -> int:
	var n := 0
	for x in arr:
		if x:
			n += 1
	return n


func show_online_menu() -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Jugar online", 34, GOLD)
	_lbl("Cada jugador usa su propio móvil. Una persona crea la sala y comparte el código con los demás.", 17, MUTED)
	_end_panel()
	if OS.has_feature("web"):
		_btn("Cambiar servidor", _ask_value.bind("url"), Color("#33465f"))
		_btn("Tu nombre: " + _short(online_name, "sin nombre"), _ask_value.bind("name"), Color("#33465f"))
		_btn("Código de sala: " + _short(online_code, "solo para unirte"), _ask_value.bind("code"), Color("#33465f"))
	else:
		online_url_edit = _field(online_url, "Servidor (ws://... o wss://...)")
		online_url_edit.text_changed.connect(func(t: String): online_url = t)
		online_name_edit = _field(online_name, "Tu nombre")
		online_name_edit.text_changed.connect(func(t: String): online_name = t)
		online_code_edit = _field(online_code, "Código de sala (solo para unirte)")
		online_code_edit.text_changed.connect(func(t: String): online_code = t)
	_btn("Crear sala", _online_go.bind(true), GREEN)
	_btn("Unirse a sala", _online_go.bind(false), Color("#2c4f7c"))
	_btn("Volver", show_menu, GREY)


## Abre el cuadro nativo del navegador para escribir un valor (funciona en móviles).
func _ask_value(key: String) -> void:
	var title := ""
	var current := ""
	match key:
		"url":
			title = "Dirección del servidor"
			current = online_url
		"name":
			title = "Tu nombre"
			current = online_name
		"code":
			title = "Código de la sala"
			current = online_code
	var res = JavaScriptBridge.eval("prompt(%s, %s)" % [JSON.stringify(title), JSON.stringify(current)])
	if res != null:
		var v := String(res).strip_edges()
		match key:
			"url":
				online_url = v
			"name":
				online_name = v
			"code":
				online_code = v.to_upper()
	show_online_menu()


func _online_go(create: bool) -> void:
	online_url = online_url.strip_edges()
	online_name = online_name.strip_edges()
	online_code = online_code.strip_edges()
	online_create = create
	if online_name == "":
		online_name = "Jugador"
	if not create and online_code == "":
		_toast("Escribe el código de la sala.")
		return
	online_role_seen = false
	online_role_pending = false
	online_last = {}
	_clear()
	_lbl("Conectando con el servidor...", 24, MUTED)
	net.connect_to(online_url)


func _on_connected() -> void:
	_toast("Conectado. Creando o uniéndote a la sala..." if online_create else "Conectado. Uniéndote a la sala...")
	if online_create:
		net.create_room(online_name)
	else:
		net.join_room(online_code, online_name)


func _on_connect_failed() -> void:
	_clear()
	_begin_panel(RED)
	_lbl("No se pudo conectar con el servidor. Revisa la dirección.", 22, CREAM)
	_end_panel()
	_btn("Volver", show_online_menu, GREY)


func _on_online_state(d: Dictionary) -> void:
	online_last = d
	if d.get("lobby", true):
		_show_lobby(d)
		return
	if not online_role_seen:
		online_role_seen = true
		_show_online_role(d)
		return
	if online_role_pending:
		return
	_render_online_board()


func _show_lobby(d: Dictionary) -> void:
	online_spun = false
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Sala %s" % d.get("code", ""), 36, GOLD)
	_lbl("Comparte este código con tus amigos.", 17, MUTED)
	var names: Array = d.get("names", [])
	for i in names.size():
		_lbl("• %s%s" % [names[i], " (anfitrión)" if i == 0 else ""], 20)
	_end_panel()
	if d.get("host", false):
		if names.size() >= 5:
			_btn("Empezar partida (%d jugadores)" % names.size(), net.start_game, GREEN)
		else:
			_lbl("Faltan %d jugadores (mínimo 5)." % (5 - names.size()), 18, MUTED)
	else:
		_lbl("Esperando a que el anfitrión empiece la partida...", 18, MUTED)


func _show_online_role(d: Dictionary) -> void:
	online_role_pending = true
	_clear(true)
	_begin_panel(NAVY)
	_lbl("Tu sobre secreto", 26, GOLD)
	_lbl("Solo tú puedes ver tu rol.", 17, MUTED)
	_end_panel()
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 90)
	cur.add_child(gap)
	var center := CenterContainer.new()
	cur.add_child(center)
	var env := Envelope.new()
	env.set_role(d.get("role", "liberal"))
	center.add_child(env)
	var team: Array = d.get("team", [])
	if team.size() > 0:
		_begin_panel(DARK)
		_lbl("Tu equipo: %s" % _join(team), 20)
		_end_panel()
	elif d.get("role", "") == "hitler":
		_begin_panel(DARK)
		_lbl("No conoces a ningún fascista.", 20)
		_end_panel()
	_btn("Ocultar y empezar", _online_role_done, GREY)


func _online_spun_done(_idx: int, _who: String) -> void:
	online_spun = true
	_render_online_board()


func _online_role_done() -> void:
	online_role_pending = false
	_render_online_board()


func _online_act(action: String, arg: int) -> void:
	net.act(action, arg)


## Las cartas de ¡Ja!/¡Nein! y de la mano llegan con idx y la acción ya bindeada.
func _online_pick(idx: int, action: String) -> void:
	if action == "vote":
		net.act("vote", 1 if idx == 0 else 0)
	else:
		net.act(action, idx)


func _hand_cards(hand: Array, sz: Vector2) -> Array:
	var res: Array = []
	for k in hand:
		var c := SwipeCard.new()
		c.setup(String(k), false, sz)
		res.append(c)
	return res


func _render_online_board() -> void:
	var d: Dictionary = online_last
	if d.is_empty():
		return
	var pub: Dictionary = d["public"]
	var names: Array = pub["names"]
	var alive: Array = pub["alive"]
	var seat: int = d["seat"]
	var pres: int = pub["president"]
	var chan: int = pub["chancellor"]
	var phase: String = pub["phase"]
	_clear()
	if phase == "over":
		_show_online_end(d)
		return
	if not online_spun and phase == "nominate" and pub["enacted_f"] == 0 and pub["enacted_l"] == 0 and pub["tracker"] == 0:
		_show_roulette(names, pres, "La partida está lista", "La ruleta elige al primer Rey.", _online_spun_done)
		return
	role_btn.visible = true

	var fas := BoardView.new()
	fas.set_board("fascist", pub["enacted_f"], d["powers"], 0)
	cur.add_child(fas)
	var lib := BoardView.new()
	lib.set_board("liberal", pub["enacted_l"], [], pub["tracker"])
	cur.add_child(lib)
	var ft := FailTrack.new()
	ft.set_tracker(pub["tracker"])
	cur.add_child(ft)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	cur.add_child(row)
	var dp := PileView.new()
	row.add_child(dp)
	dp.set_pile(pub["draw"], Txt.DRAW)
	var dc := PileView.new()
	row.add_child(dc)
	dc.set_pile(pub["discard"], Txt.DISCARD)

	_begin_panel(NAVY)
	_lbl("%s: %s     %s: %s" % [Txt.PRES, _oname(names, pres), Txt.CHAN, _oname(names, chan)], 20, GOLD)
	_lbl(pub["event"], 17, MUTED)
	_end_panel()

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	cur.add_child(grid)
	for i in names.size():
		var panel := PanelContainer.new()
		var sb := _sb(Color("#263754") if alive[i] else Color("#353535"))
		if i == pres or i == chan:
			sb.set_border_width_all(4)
			sb.border_color = GOLD
		panel.add_theme_stylebox_override("panel", sb)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tags: Array = []
		if i == seat:
			tags.append("tú")
		if i == pres:
			tags.append(Txt.PRES)
		if i == chan:
			tags.append(Txt.CHAN)
		if not alive[i]:
			tags.append("eliminado")
		var t := Label.new()
		t.text = String(names[i]) + ("\n" + _join(tags) if tags.size() > 0 else "")
		t.add_theme_font_size_override("font_size", int(18 * TXT))
		t.add_theme_color_override("font_color", CREAM if alive[i] else MUTED)
		panel.add_child(t)
		grid.add_child(panel)

	var alive_seat: bool = alive[seat]
	match phase:
		"nominate":
			if seat == pres:
				_lbl("Propón un Consejero:", 22, GOLD)
				for i in d["eligible"]:
					_btn(String(names[i]), _online_act.bind("nominate", i), Color("#2c4f7c"))
			else:
				_lbl("Esperando a que %s proponga un Consejero..." % _oname(names, pres), 18, MUTED)
		"vote":
			_lbl("Votación para %s como %s" % [_oname(names, d["nominee"]), Txt.CHAN], 20, GOLD)
			if not alive_seat:
				_lbl("Estás eliminado. Solo puedes mirar.", 18, MUTED)
			elif d["my_voted"]:
				_lbl("Voto enviado. Esperando a los demás (%d/%d)." % [d["votes_in"], _count_true(alive)], 18, MUTED)
			else:
				var ja := SwipeCard.new()
				ja.setup_thumb(true, Vector2(150, 200))
				var nein := SwipeCard.new()
				nein.setup_thumb(false, Vector2(150, 200))
				_stage([ja, nein], _online_pick.bind("vote"), "Desliza hacia arriba la carta de tu voto")
		"discard_pres":
			if seat == pres:
				var cards: Array = _hand_cards(d["hand"], Vector2(130, 190))
				_stage(cards, _online_pick.bind("discard"), "Desliza hacia arriba la que quieras descartar")
				_animate_draw(cards, d["hand"])
			else:
				_lbl("%s está descartando una política en secreto." % _oname(names, pres), 18, MUTED)
		"discard_chan":
			if seat == chan:
				var cards2: Array = _hand_cards(d["hand"], Vector2(140, 200))
				_stage(cards2, _online_pick.bind("enact"), "Desliza hacia arriba la que quieras promulgar")
				_animate_draw(cards2, d["hand"])
				if d["can_veto"]:
					_btn("Proponer veto", _online_act.bind("veto_request", 0), RED)
			else:
				_lbl("%s está promulgando una política en secreto." % _oname(names, chan), 18, MUTED)
		"veto_wait":
			if seat == pres:
				_lbl("El Consejero propone un veto. ¿Aceptas descartar ambas políticas?", 20)
				_btn("Aceptar veto", _online_act.bind("veto", 1), GREEN)
				_btn("Rechazar veto", _online_act.bind("veto", 0), RED)
			else:
				_lbl("Esperando la respuesta del Rey al veto.", 18, MUTED)
		"exec":
			if seat == pres:
				_online_power(d)
			else:
				_lbl("%s está usando su poder presidencial." % _oname(names, pres), 18, MUTED)


func _online_power(d: Dictionary) -> void:
	var names: Array = d["public"]["names"]
	var pw: String = d["power"]
	var priv: Dictionary = d["private"]
	_begin_panel(NAVY)
	_lbl("Poder presidencial (en secreto)", 24, GOLD)
	_end_panel()
	if priv.has("peek"):
		_lbl("Las 3 siguientes leyes, de arriba abajo:", 18)
		_cards_row(priv["peek"])
		_btn("Ocultar y continuar", _online_act.bind("power_done", 0), GREY)
		return
	if priv.has("investigated"):
		var inv: Array = priv["investigated"]
		var party: String = Txt.LIB if inv[1] == "liberal" else Txt.FAS
		_lbl("%s pertenece a: %s" % [_oname(names, inv[0]), party], 26, GOLD)
		_btn("Ocultar y continuar", _online_act.bind("power_done", 0), GREY)
		return
	var action := ""
	match pw:
		"investigate":
			action = "investigate"
			_lbl("Elige a quién investigar (en secreto):", 20)
		"special":
			action = "special"
			_lbl("Elige al siguiente Rey:", 20)
		"execute":
			action = "execute"
			_lbl("Elige a quién eliminar (no se revela su rol):", 20)
	for i in d["targets"]:
		var col := RED if pw == "execute" else Color("#2c4f7c")
		_btn(String(names[i]), _online_act.bind(action, i), col)


func _show_online_end(d: Dictionary) -> void:
	var pub: Dictionary = d["public"]
	var names: Array = pub["names"]
	var lib_win: bool = pub["winner"] == "liberal"
	_begin_panel(BLUE if lib_win else RED)
	_lbl("Ganan los Libertadores" if lib_win else "Ganan los Tiranos", 36, GOLD)
	_lbl(String(d.get("win", "")), 18)
	_end_panel()
	_lbl("Roles de la partida", 22, GOLD)
	var roles: Array = d.get("roles", [])
	for i in roles.size():
		var r: String = roles[i]
		_begin_panel(BLUE if r == "liberal" else (RED if r == "fascist" else DARK))
		_lbl("%s: %s" % [_oname(names, i), Txt.ROLE_NAME[r]], 20)
		_end_panel()
	_btn("Menú principal", show_menu, GREY)


# ---------- sonido y encaje en pantalla ----------

func _toggle_sound() -> void:
	Sfx.muted = not Sfx.muted
	_update_sound_btn()
	if not Sfx.muted:
		Sfx.play("tap")


func _update_sound_btn() -> void:
	sound_btn.text = "Sonido: NO" if Sfx.muted else "Sonido: SÍ"


## Sin scroll: si el contenido no cabe, se reduce para que quepa entero en la pantalla.
func _process(_delta: float) -> void:
	var vp := get_viewport_rect().size
	var need := box.get_combined_minimum_size()
	if need.y <= 0.0:
		return
	var s := minf(1.0, (vp.y - 90.0) / need.y)
	box.scale = Vector2(s, s)
	box.size = Vector2((vp.x - 40.0) / s, need.y)
	var y := 70.0
	if center_screen:
		y = maxf(70.0, (vp.y - need.y * s) * 0.5)
	box.position = Vector2(20.0, y)


# ---------- primer Rey (ruleta victoriana) ----------

func _show_draw_president() -> void:
	var names: Array = []
	for p in game.players:
		names.append(String(p["name"]))
	var final_idx := randi() % names.size()
	_show_roulette(names, final_idx, "La partida está lista", "Gira la ruleta para elegir al primer Rey.", _start_first_round)


## Pantalla con la ruleta. Al terminar de girar, el botón pasa a "Continuar" y llama a done.
func _show_roulette(names: Array, final_idx: int, title: String, text: String, done: Callable) -> void:
	_clear(true)
	_begin_panel(NAVY)
	_lbl(title, 28, GOLD)
	_lbl(text, 19, CREAM)
	_end_panel()
	var wheel := Roulette.new()
	wheel.set_players(names)
	var center := CenterContainer.new()
	cur.add_child(center)
	center.add_child(wheel)
	var result := _lbl("", 30, GOLD)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var st := {"spun": false, "btn": null}
	st["btn"] = _btn("Girar la ruleta", func():
		if st["spun"]:
			done.call(final_idx, names[final_idx])
			return
		st["spun"] = true
		var b: Button = st["btn"]
		b.disabled = true
		wheel.spin(final_idx, func():
			result.text = "El Rey es %s" % names[final_idx]
			Sfx.play("enact")
			b.text = "Continuar"
			b.disabled = false), GREEN)


func _start_first_round(idx: int, who: String) -> void:
	game.president = idx
	game.last_event = "Nueva partida. El primer Rey es %s." % who
	show_board()


func _find_button_in_cur() -> Button:
	for c in cur.get_children():
		if c is Button:
			return c
	return null
