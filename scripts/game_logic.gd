class_name GameLogic
extends RefCounted
## Reglas puras de La Corona Real (sin interfaz).
## Equivalencias: LIBERTADOR = Juez, FASCIST = Cartel, HITLER = Consejero Corrupto.
## Cartas: "L" = Ley Justa, "F" = Ley Corrupta. La carta de arriba del mazo es la ultima del array.

const LIBERTADOR := "liberal"
const FASCIST := "fascist"
const HITLER := "hitler"

var players: Array = []        # [{name, role, alive}]
var draw_pile: Array = []
var discard_pile: Array = []
var hand: Array = []           # cartas en manos del Rey o del Consejero
var enacted_l := 0
var enacted_f := 0
var tracker := 0               # gobiernos fallidos seguidos (0..3)
var president := -1
var chancellor := -1
var nominee := -1
var prev_president := -1       # limites de mandato
var prev_chancellor := -1
var special_return := -1       # presidente que convoco la designacion extraordinaria
var phase := "nominate"        # nominate, vote, discard_pres, discard_chan, veto_wait, exec, over
var pending_power := ""        # peek, investigate, special, execute
var winner := ""               # LIBERTADOR o FASCIST
var win_reason := ""
var last_event := ""
var last_votes: Dictionary = {}
var investigated: Array = []   # jugadores ya auditados (solo se audita una vez)


static func composition(n: int) -> Dictionary:
	# Libertadores y Cartel (sin contar al Consejero Corrupto, que siempre existe)
	match n:
		5: return {"liberal": 3, "fascist": 1}
		6: return {"liberal": 4, "fascist": 1}
		7: return {"liberal": 4, "fascist": 2}
		8: return {"liberal": 5, "fascist": 2}
		9: return {"liberal": 5, "fascist": 3}
		10: return {"liberal": 6, "fascist": 3}
	return {"liberal": 0, "fascist": 0}


func setup(names: Array) -> void:
	var n := names.size()
	var comp := composition(n)
	var roles: Array = []
	for _i in comp["liberal"]:
		roles.append(LIBERTADOR)
	for _i in comp["fascist"]:
		roles.append(FASCIST)
	roles.append(HITLER)
	roles.shuffle()
	players = []
	for i in n:
		players.append({"name": names[i], "role": roles[i], "alive": true})
	draw_pile = []
	for _i in 11:
		draw_pile.append("L")
	for _i in 6:
		draw_pile.append("F")
	draw_pile.shuffle()
	discard_pile = []
	hand = []
	enacted_l = 0
	enacted_f = 0
	tracker = 0
	prev_president = -1
	prev_chancellor = -1
	special_return = -1
	investigated = []
	pending_power = ""
	winner = ""
	win_reason = ""
	president = randi() % n
	chancellor = -1
	nominee = -1
	phase = "nominate"
	last_event = "Nueva partida. El primer Rey es %s." % players[president]["name"]


# ---------- consultas ----------

func alive_indices() -> Array:
	var res: Array = []
	for i in players.size():
		if players[i]["alive"]:
			res.append(i)
	return res


func next_alive_after(i: int) -> int:
	var n := players.size()
	for step in range(1, n + 1):
		var j := (i + step) % n
		if players[j]["alive"]:
			return j
	return i


func eligible_chancellors() -> Array:
	var res: Array = []
	for i in players.size():
		if i == president or not players[i]["alive"]:
			continue
		if i == prev_chancellor:
			continue
		if alive_indices().size() >= 7 and i == prev_president:
			continue
		res.append(i)
	return res


func power_for(fascist_count: int) -> String:
	if fascist_count < 1 or fascist_count > 5:
		return ""
	var n := players.size()
	var table: Array
	if n <= 6:
		table = ["", "", "peek", "execute", "execute"]
	elif n <= 8:
		table = ["", "investigate", "special", "execute", "execute"]
	else:
		table = ["investigate", "investigate", "special", "execute", "execute"]
	return table[fascist_count - 1]


func can_request_veto() -> bool:
	return enacted_f >= 5 and phase == "discard_chan"


# ---------- eleccion de gobierno ----------

func nominate(i: int) -> void:
	nominee = i
	phase = "vote"
	last_event = "%s propone a %s como Consejero." % [players[president]["name"], players[i]["name"]]


## vote_map: {indice_jugador: true (Si) / false (No)} de los jugadores vivos.
func resolve_vote(vote_map: Dictionary) -> bool:
	last_votes = vote_map
	var yes := 0
	var no := 0
	for k in vote_map:
		if vote_map[k]:
			yes += 1
		else:
			no += 1
	if yes > no:
		chancellor = nominee
		prev_president = president
		prev_chancellor = chancellor
		if players[chancellor]["role"] == HITLER and enacted_f >= 3:
			_win(FASCIST, "El Consejero Corrupto llego a Consejero tras 3 leyes corruptas.")
			return true
		last_event = "Gobierno aprobado (%d a %d): %s es Rey y %s es Consejero." % [
			yes, no, players[president]["name"], players[chancellor]["name"]]
		if enacted_f >= 3:
			last_event += " Se confirma que el Consejero no es El Esclavista."
		hand = _draw_n(3)
		phase = "discard_pres"
		return true
	tracker += 1
	last_event = "Gobierno rechazado (%d a %d). Fallos seguidos: %d/3." % [yes, no, tracker]
	_fail_government()
	return false


# ---------- legislacion ----------

func president_discard(idx: int) -> void:
	discard_pile.append(hand[idx])
	hand.remove_at(idx)
	phase = "discard_chan"
	last_event = "El Rey ha descartado una ley en secreto y pasa dos al Consejero."


func chancellor_enact(idx: int) -> void:
	var card: String = hand[idx]
	var other: String = hand[1 - idx]
	discard_pile.append(other)
	hand = []
	_enact(card, true, "")


func request_veto() -> void:
	phase = "veto_wait"
	last_event = "El Consejero propone un recurso de apelacion (veto)."


func veto_answer(accept: bool) -> void:
	if accept:
		discard_pile.append_array(hand)
		hand = []
		tracker += 1
		last_event = "El Rey acepta el veto: ambas leyes se descartan. Fallos seguidos: %d/3." % tracker
		_fail_government()
	else:
		phase = "discard_chan"
		last_event = "El Rey rechaza el veto. El Consejero debe promulgar una ley."


# ---------- poderes ejecutivos ----------

func peek_top() -> Array:
	_ensure_draw(3)
	var res: Array = []
	var n := draw_pile.size()
	for i in range(min(3, n)):
		res.append(draw_pile[n - 1 - i])
	return res


func investigable_indices() -> Array:
	var res: Array = []
	for i in players.size():
		if i == president or not players[i]["alive"]:
			continue
		if i in investigated:
			continue
		res.append(i)
	return res


func investigate(i: int) -> String:
	investigated.append(i)
	return "liberal" if players[i]["role"] == LIBERTADOR else "fascist"


func exec_special(i: int) -> void:
	special_return = president
	president = i
	chancellor = -1
	nominee = -1
	pending_power = ""
	phase = "nominate"
	last_event = "%s es designado Rey de forma extraordinaria." % players[i]["name"]


func exec_kill(i: int) -> void:
	players[i]["alive"] = false
	last_event = "%s ha sido inhabilitado del tribunal." % players[i]["name"]
	if players[i]["role"] == HITLER:
		_win(LIBERTADOR, "Se inhabilito al Consejero Corrupto.")
		return
	_next_round()


func end_power() -> void:
	pending_power = ""
	_next_round()


# ---------- internos ----------

func _win(team: String, reason: String) -> void:
	winner = team
	win_reason = reason
	phase = "over"


func _enact(card: String, allow_power: bool, prefix: String) -> void:
	tracker = 0  # una ley promulgada reinicia el contador de fallos
	if card == "L":
		enacted_l += 1
	else:
		enacted_f += 1
	var txt := "Se promulga una Ley Justa." if card == "L" else "Se promulga una Ley Corrupta."
	last_event = (prefix + " " + txt).strip_edges()
	if enacted_l >= 5:
		_win(LIBERTADOR, "Se han promulgado 5 Leyes Justas.")
		return
	if enacted_f >= 6:
		_win(FASCIST, "Se han promulgado 6 Leyes Corruptas.")
		return
	if allow_power and card == "F":
		var p := power_for(enacted_f)
		if p != "":
			pending_power = p
			phase = "exec"
			return
	_next_round()


func _fail_government() -> void:
	if tracker >= 3:
		tracker = 0
		prev_president = -1
		prev_chancellor = -1
		var card: String = _draw_n(1)[0]
		_enact(card, false, "Tres fallos seguidos: se promulga la ley de arriba del mazo.")
		return
	_next_round()


func _next_round() -> void:
	if winner != "":
		phase = "over"
		return
	if special_return != -1:
		president = next_alive_after(special_return)
		special_return = -1
	else:
		president = next_alive_after(president)
	chancellor = -1
	nominee = -1
	hand = []
	pending_power = ""
	phase = "nominate"


func _ensure_draw(k: int) -> void:
	if draw_pile.size() < k:
		draw_pile.append_array(discard_pile)
		discard_pile = []
		draw_pile.shuffle()


func _draw_n(k: int) -> Array:
	_ensure_draw(3)
	var res: Array = []
	for _i in k:
		res.append(draw_pile.pop_back())
	return res


# ---------- vista para la interfaz y para el juego en red ----------

## Poderes de las casillas 1 a 5 del tablero fascista ("" = sin poder).
func power_list() -> Array:
	var res: Array = []
	for k in range(1, 6):
		res.append(power_for(k))
	return res


## Estado público: lo que ven todos los dispositivos.
func public_state() -> Dictionary:
	var names: Array = []
	var alive: Array = []
	for p in players:
		names.append(p["name"])
		alive.append(p["alive"])
	return {
		"names": names,
		"alive": alive,
		"president": president,
		"chancellor": chancellor,
		"phase": phase,
		"enacted_l": enacted_l,
		"enacted_f": enacted_f,
		"tracker": tracker,
		"draw": draw_pile.size(),
		"discard": discard_pile.size(),
		"event": last_event,
		"winner": winner,
	}


## Lo que puede ver el móvil del jugador i: lo público, su rol y, solo si le toca, su mano.
func view_for(i: int) -> Dictionary:
	var v := {"public": public_state(), "role": "", "hand": []}
	if i >= 0 and i < players.size():
		v["role"] = players[i]["role"]
		if (i == president and phase == "discard_pres") or (i == chancellor and phase == "discard_chan"):
			v["hand"] = hand.duplicate()
	return v
