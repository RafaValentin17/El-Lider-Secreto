class_name Txt
extends RefCounted
## Textos de la interfaz con los nombres del juego original (version en espanol).

const TITLE := "El Líder Secreto"
const LIB := "Libertador"
const FAS := "Tirano"
const HIT := "El Esclavista"
const PRES := "Rey"
const CHAN := "Consejero"
const LIB_POL := "Política liberal"
const FAS_POL := "Política tiránica"
const TRACK := "Marcador de elecciones"
const DRAW := "Pila de robar"
const DISCARD := "Pila de descarte"
const JA := "¡Ja!"
const NEIN := "¡Nein!"

const ROLE_NAME := {"liberal": "LIBERTADOR", "fascist": "TIRANO", "hitler": "HITLER"}
const ROLE_DESC := {
	"liberal": "Eres Libertador. Ganas si se promulgan 5 políticas libertadoras o si matáis a El Esclavista. No sabes quién es quién.",
	"fascist": "Eres Tirano. Ganas si se promulgan 6 políticas tiránicas, o si El Esclavista llega a Consejero tras la tercera política tiránica. Conoces a El Esclavista.",
	"hitler": "Eres El Esclavista. Ganas si llegas a Consejero tras la tercera política tiránica. Ojo: los libertadores quieren verte fuera.",
}

const POWER_NAME := {
	"peek": "Ojeada a políticas",
	"investigate": "Investigar lealtad",
	"special": "Llamada a elecciones extraordinarias",
	"execute": "Ejecución",
}
const POWER_SHORT := {"peek": "Ojeada", "investigate": "Investigar", "special": "Elección extra", "execute": "Ejecución"}

const RULES := """Objetivo: los libertadores deben promulgar 5 políticas libertadoras o matar a El Esclavista. Los tiranos deben promulgar 6 políticas tiránicas, o elegir a El Esclavista como Consejero tras la tercera política tiránica.

Ronda: 1) el Rey propone un Consejero. 2) Todos votan ¡Ja! o ¡Nein! y se revelan a la vez. Gana el ¡Ja! con mayoría; el empate cuenta como ¡Nein!. 3) Si gana, el Rey roba 3 políticas, descarta 1 en secreto y pasa 2 al Consejero, que promulga una y descarta la otra. 4) Si la política promulgada da poder, el Rey lo usa antes de la siguiente ronda.

Marcador de elecciones: si el gobierno no sale, el marcador sube. Al tercer fracaso seguido se promulga la política de arriba de la pila de robar, sin poder, y se olvidan los límites de mandato. El marcador vuelve a cero cuando se promulga una política.

Veto: tras la quinta política tiránica, el Consejero puede proponer veto. Si el Rey lo acepta, se descartan ambas políticas y cuenta como un fracaso.

Poderes: ojeada a las tres siguientes políticas; investigar lealtad (cada jugador solo una vez); llamada a elecciones extraordinarias (el Rey elige al siguiente candidato y después la presidencia vuelve a su orden); ejecución (si es El Esclavista, ganan los libertadores).

Límites de mandato: el Consejero anterior nunca puede repetir. En partidas de 7 o más jugadores, el Rey anterior tampoco puede ser Consejero.

Créditos: basado en Secret El Esclavista (Mike Boxleiter, Tommy Maranges y Mac Schubert; Goat, Wolf & Cabbage), licencia CC BY-NC-SA 4.0. Esta versión cambia la maquetación y los textos. Uso no comercial."""

## Reglas por secciones: cada una con su color, sus puntos y un ejemplo.
const RULE_SECTIONS := [
	{
		"title": "1. Objetivo",
		"color": "#6b4f10",
		"lines": [
			"Libertadores: promulgar 5 políticas libertadoras, o matar a El Esclavista.",
			"Tiranos: promulgar 6 políticas tiránicas, o que El Esclavista llegue a Consejero tras la 3.ª política tiránica.",
		],
		"example": "Ya hay 3 políticas tiránicas en el tablero. Si El Esclavista sale elegido Consejero en una votación que gana, el equipo fascista gana al instante.",
	},
	{
		"title": "2. Equipos y reparto",
		"color": "#3b1f5c",
		"lines": [
			"Libertadores: la mayoría. No saben quién es quién.",
			"Tiranos: conocen a El Esclavista desde el principio.",
			"El Esclavista: lidera el equipo fascista.",
			"Con 5 jugadores: 3 libertadores, 1 fascista y El Esclavista.",
		],
		"example": "Partida de 5: cada jugador recibe en secreto una carta de rol. Una de ellas es El Esclavista, otra es Tirano y las otras tres son Libertadores.",
	},
	{
		"title": "3. Preparación",
		"color": "#2d4a3e",
		"lines": [
			"Pila de robar: 6 políticas libertadoras y 11 tiranos, mezcladas boca abajo.",
			"El primer Rey se elige al azar.",
			"Con 5 o 6 jugadores, El Esclavista sabe quién es el fascista. Con 7 a 10, no.",
		],
		"example": "Al empezar, cada jugador mira su carta en secreto. Después se entrega el marcador de Rey al jugador elegido al azar.",
	},
	{
		"title": "4. Ronda: elegir Consejero",
		"color": "#1f5f9e",
		"lines": [
			"El Rey propone un Consejero entre los jugadores vivos.",
			"El Consejero anterior nunca puede repetir.",
			"En partidas de 7 o más jugadores, el Rey anterior tampoco puede ser Consejero.",
		],
		"example": "Partida de 7. El gobierno anterior fue Ana de Presidenta y Luis de Consejero. La siguiente ronda pasa a Marta, que no puede proponer a Luis, ni a Ana si Ana fue Presidenta.",
	},
	{
		"title": "5. Votación",
		"color": "#2c7a4b",
		"lines": [
			"Todos los jugadores vivos, incluidos Rey y Consejero, votan ¡Ja! o ¡Nein!.",
			"Los votos se revelan a la vez. Gana el ¡Ja! si tiene más votos.",
			"Si hay empate, el gobierno fracasa.",
		],
		"example": "Partida de 7: 4 votan ¡Ja! y 3 ¡Nein!, el gobierno sale. Con 3 ¡Ja! y 3 ¡Nein! hay empate y fracasa.",
	},
	{
		"title": "6. Gobierno fracasado y marcador",
		"color": "#8c2f39",
		"lines": [
			"Si el gobierno fracasa, el Rey pasa al siguiente jugador y el marcador sube 1.",
			"Al tercer fracaso seguido se promulga la política de arriba de la pila de robar, sin votación y sin poder.",
			"El marcador vuelve a 0 cada vez que se promulga una política.",
		],
		"example": "Fracaso 1: marcador en 1. Fracaso 2: marcador en 2. Fracaso 3: se promulga la primera carta del mazo y el marcador vuelve a 0.",
	},
	{
		"title": "7. Sesión legislativa",
		"color": "#a35c1e",
		"lines": [
			"El Rey roba 3 políticas, las mira en secreto y descarta 1 boca abajo.",
			"Pasa las 2 restantes al Consejero, que mira en secreto, descarta 1 y promulga la otra.",
			"Durante la sesión no se puede hablar ni hacer señas.",
		],
		"example": "El Rey roba liberal, fascista y fascista. Descarta un fascista y pasa liberal y fascista. El Consejero descarta el fascista y promulga la liberal.",
	},
	{
		"title": "8. Poderes de las políticas tiránicas",
		"color": "#7a1f1f",
		"lines": [
			"Una política tiránica da poder solo si la casilla que cubre lo tiene impreso.",
			"Ojeada: mirar las 3 próximas políticas del mazo, sin cambiar el orden.",
			"Investigar lealtad: ver el carné de partido de un jugador (su bando, no su rol). Solo una vez por jugador.",
			"Elección extraordinaria: elegir al siguiente Rey. Después la rotación sigue su curso.",
			"Ejecución: eliminar a un jugador. Si es El Esclavista, ganan los libertadores.",
			"El poder se usa una sola vez y el Rey decide cómo.",
		],
		"example": "Partida de 7: la 2.ª política tiránica da Investigar. El Rey audita a Marta y ve que es Libertador. Puede contarlo o mentir.",
	},
	{
		"title": "9. Veto",
		"color": "#4a1a5c",
		"lines": [
			"Tras la 5.ª política tiránica, el Consejero puede proponer veto en lugar de promulgar.",
			"Si el Rey acepta, se descartan las 2 políticas y el marcador sube 1.",
			"Si lo rechaza, el Consejero debe promulgar una de las dos.",
		],
		"example": "El Consejero propone veto. El Rey acepta: ambas cartas van al descarte y el marcador pasa a 1.",
	},
	{
		"title": "10. Consejos",
		"color": "#2e4057",
		"lines": [
			"Lo que sabes en secreto (investigaciones, cartas vistas) lo puedes contar o mentir.",
			"El Esclavista solo está obligado a decir la verdad si lo asesinan o si llega a Consejero tras 3 tiranos.",
			"Los tiranos ganan sobre todo eligiendo a El Esclavista como Consejero.",
		],
		"example": "Un liberal investiga a Marta, que es Tirano, y dice que es Libertador. Mentir sobre lo que se sabe en secreto está permitido.",
	},
	{
		"title": "Créditos",
		"color": "#333333",
		"lines": [
			"Basado en Secret El Esclavista (Mike Boxleiter, Tommy Maranges y Mac Schubert; Goat, Wolf & Cabbage), licencia CC BY-NC-SA 4.0. Uso no comercial.",
		],
	},
]
