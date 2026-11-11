class_name Net
extends Node
## Red del juego. El servidor (headless) guarda las salas y decide todo. Cada móvil recibe solo su vista.

signal state_changed(data: Dictionary)
signal error_msg(text: String)
signal connected_ok
signal connect_failed

const MIN_PLAYERS := 5
const MAX_PLAYERS := 10
const CODE_CHARS := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

var rooms: Dictionary = {}       # código -> sala
var peer_room: Dictionary = {}   # id de móvil -> código


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_fail)
	multiplayer.server_disconnected.connect(_on_fail)


# ---------- lado cliente (los móviles) ----------

func connect_to(url: String) -> void:
	var peer := WebSocketMultiplayerPeer.new()
	if peer.create_client(url) != OK:
		connect_failed.emit()
		return
	multiplayer.multiplayer_peer = peer


func create_room(player_name: String) -> void:
	rpc_id(1, "c_create", player_name)


func join_room(code: String, player_name: String) -> void:
	rpc_id(1, "c_join", code, player_name)


func start_game() -> void:
	rpc_id(1, "c_start")


func act(action: String, arg: int) -> void:
	rpc_id(1, "c_act", action, arg)


func _on_connected_ok() -> void:
	connected_ok.emit()


func _on_fail() -> void:
	connect_failed.emit()


@rpc("authority", "reliable")
func s_state(data: Dictionary) -> void:
	state_changed.emit(data)


@rpc("authority", "reliable")
func s_error(text: String) -> void:
	error_msg.emit(text)


# ---------- lado servidor ----------

func start_server(port: int) -> void:
	var peer := WebSocketMultiplayerPeer.new()
	if peer.create_server(port) != OK:
		push_error("No se pudo abrir el puerto %d" % port)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_gone)
	print("El Líder Secreto: servidor escuchando en el puerto %d" % port)


@rpc("any_peer", "reliable")
func c_create(player_name: String) -> void:
	var peer := multiplayer.get_remote_sender_id()
	if peer_room.has(peer):
		_err(peer, "Ya estás en una sala.")
		return
	var code := _new_code()
	rooms[code] = {"seats": [], "names": [], "game": null, "started": false, "votes": {}, "private": {}}
	_seat(code, peer, player_name)


@rpc("any_peer", "reliable")
func c_join(code: String, player_name: String) -> void:
	var peer := multiplayer.get_remote_sender_id()
	code = code.strip_edges().to_upper()
	if peer_room.has(peer):
		_err(peer, "Ya estás en una sala.")
		return
	if not rooms.has(code):
		_err(peer, "No existe la sala %s." % code)
		return
	var r: Dictionary = rooms[code]
	if r["started"]:
		_err(peer, "Esa partida ya ha empezado.")
		return
	if (r["seats"] as Array).size() >= MAX_PLAYERS:
		_err(peer, "La sala está llena.")
		return
	_seat(code, peer, player_name)


@rpc("any_peer", "reliable")
func c_start() -> void:
	var peer := multiplayer.get_remote_sender_id()
	if not peer_room.has(peer):
		return
	var code: String = peer_room[peer]
	var r: Dictionary = rooms[code]
	var seats: Array = r["seats"]
	if seats[0] != peer:
		_err(peer, "Solo el anfitrión puede empezar.")
		return
	if seats.size() < MIN_PLAYERS:
		_err(peer, "Hacen falta al menos %d jugadores." % MIN_PLAYERS)
		return
	var g := GameLogic.new()
	g.setup(r["names"])
	r["game"] = g
	r["started"] = true
	_push(code)


@rpc("any_peer", "reliable")
func c_act(action: String, arg: int) -> void:
	var peer := multiplayer.get_remote_sender_id()
	if not peer_room.has(peer):
		return
	var code: String = peer_room[peer]
	var r: Dictionary = rooms[code]
	if not r["started"]:
		return
	var g: GameLogic = r["game"]
	var seat: int = (r["seats"] as Array).find(peer)
	if not _apply(r, g, seat, action, arg):
		_err(peer, "Ahora mismo no puedes hacer eso.")
		return
	_after(r, g)
	_push(code)


func _apply(r: Dictionary, g: GameLogic, seat: int, action: String, arg: int) -> bool:
	var priv: Dictionary = r["private"]
	var votes: Dictionary = r["votes"]
	match action:
		"nominate":
			if g.phase != "nominate" or seat != g.president:
				return false
			if not g.eligible_chancellors().has(arg):
				return false
			g.nominate(arg)
		"vote":
			if g.phase != "vote" or not g.players[seat]["alive"] or votes.has(seat):
				return false
			votes[seat] = arg == 1
			if votes.size() >= g.alive_indices().size():
				g.resolve_vote(votes)
				r["votes"] = {}
		"discard":
			if g.phase != "discard_pres" or seat != g.president:
				return false
			if arg < 0 or arg >= g.hand.size():
				return false
			g.president_discard(arg)
		"enact":
			if g.phase != "discard_chan" or seat != g.chancellor:
				return false
			if arg < 0 or arg > 1:
				return false
			g.chancellor_enact(arg)
		"veto_request":
			if seat != g.chancellor or not g.can_request_veto():
				return false
			g.request_veto()
		"veto":
			if g.phase != "veto_wait" or seat != g.president:
				return false
			g.veto_answer(arg == 1)
		"investigate":
			if g.phase != "exec" or g.pending_power != "investigate" or seat != g.president:
				return false
			if not _targets(g).has(arg):
				return false
			var party := g.investigate(arg)
			priv[seat] = {"investigated": [arg, party]}
		"special":
			if g.phase != "exec" or g.pending_power != "special" or seat != g.president:
				return false
			if not _targets(g).has(arg):
				return false
			g.exec_special(arg)
		"execute":
			if g.phase != "exec" or g.pending_power != "execute" or seat != g.president:
				return false
			if not _targets(g).has(arg):
				return false
			g.exec_kill(arg)
		"power_done":
			if g.phase != "exec" or seat != g.president or not priv.has(seat):
				return false
			g.end_power()
		_:
			return false
	return true


## Lo que se muestra en pantalla tras cada acción: el peek y la auditoría son privados del Presidente.
func _after(r: Dictionary, g: GameLogic) -> void:
	if g.phase != "exec":
		r["private"] = {}
	elif g.pending_power == "peek" and not (r["private"] as Dictionary).has(g.president):
		r["private"] = {g.president: {"peek": g.peek_top()}}


func _targets(g: GameLogic) -> Array:
	if g.phase != "exec":
		return []
	match g.pending_power:
		"investigate":
			return g.investigable_indices()
		"special", "execute":
			var res: Array = []
			for i in g.alive_indices():
				if i != g.president:
					res.append(i)
			return res
	return []


func _team(g: GameLogic, seat: int) -> Array:
	var res: Array = []
	var me: String = g.players[seat]["role"]
	for i in g.players.size():
		if i == seat:
			continue
		var other: String = g.players[i]["role"]
		if me == GameLogic.FASCIST and other != GameLogic.LIBERAL:
			res.append(g.players[i]["name"])
		elif me == GameLogic.HITLER and g.players.size() <= 6 and other == GameLogic.FASCIST:
			res.append(g.players[i]["name"])
	return res


func _view(code: String, seat: int) -> Dictionary:
	var r: Dictionary = rooms[code]
	if not r["started"]:
		return {"lobby": true, "code": code, "names": r["names"], "seat": seat, "host": seat == 0}
	var g: GameLogic = r["game"]
	var v: Dictionary = g.view_for(seat)
	v["lobby"] = false
	v["code"] = code
	v["seat"] = seat
	v["powers"] = g.power_list()
	v["nominee"] = g.nominee
	v["power"] = g.pending_power
	v["votes_in"] = (r["votes"] as Dictionary).size()
	v["my_voted"] = (r["votes"] as Dictionary).has(seat)
	v["eligible"] = g.eligible_chancellors() if (g.phase == "nominate" and seat == g.president) else []
	v["can_veto"] = g.can_request_veto() and seat == g.chancellor
	v["targets"] = _targets(g) if seat == g.president else []
	v["private"] = (r["private"] as Dictionary).get(seat, {})
	v["team"] = _team(g, seat)
	if g.phase == "over":
		var roles: Array = []
		for p in g.players:
			roles.append(p["role"])
		v["win"] = g.win_reason
		v["roles"] = roles
	return v


func _push(code: String) -> void:
	var r: Dictionary = rooms[code]
	var seats: Array = r["seats"]
	for i in seats.size():
		var peer: int = seats[i]
		if peer in multiplayer.get_peers():
			rpc_id(peer, "s_state", _view(code, i))


func _err(peer: int, text: String) -> void:
	if peer in multiplayer.get_peers():
		rpc_id(peer, "s_error", text)


func _seat(code: String, peer: int, player_name: String) -> void:
	var r: Dictionary = rooms[code]
	var seats: Array = r["seats"]
	var names: Array = r["names"]
	seats.append(peer)
	var clean := player_name.strip_edges().left(16)
	names.append(clean if clean != "" else "Jugador %d" % seats.size())
	peer_room[peer] = code
	_push(code)


func _new_code() -> String:
	var code := ""
	while code == "" or rooms.has(code):
		code = ""
		for _i in 4:
			code += CODE_CHARS[randi() % CODE_CHARS.length()]
	return code


func _on_peer_gone(peer: int) -> void:
	var code: String = peer_room.get(peer, "")
	peer_room.erase(peer)
	if code == "" or not rooms.has(code):
		return
	var r: Dictionary = rooms[code]
	if r["started"]:
		return
	var seats: Array = r["seats"]
	var names: Array = r["names"]
	var idx: int = seats.find(peer)
	if idx >= 0:
		seats.remove_at(idx)
		names.remove_at(idx)
	if seats.is_empty():
		rooms.erase(code)
	else:
		_push(code)
