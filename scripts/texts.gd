class_name Txt
extends RefCounted
## Textos de la interfaz con los nombres del juego original (version en espanol).

const TITLE := "El Líder Secreto"
const LIB := "Liberal"
const FAS := "Fascista"
const HIT := "Hitler"
const PRES := "Presidente"
const CHAN := "Canciller"
const LIB_POL := "Política liberal"
const FAS_POL := "Política fascista"
const TRACK := "Marcador de elecciones"
const DRAW := "Pila de robar"
const DISCARD := "Pila de descarte"
const JA := "¡Ja!"
const NEIN := "¡Nein!"

const ROLE_NAME := {"liberal": "LIBERAL", "fascist": "FASCISTA", "hitler": "HITLER"}
const ROLE_DESC := {
	"liberal": "Eres Liberal. Ganas si se promulgan 5 políticas liberales o si matáis a Hitler. No sabes quién es quién.",
	"fascist": "Eres Fascista. Ganas si se promulgan 6 políticas fascistas, o si Hitler llega a Canciller tras la tercera política fascista. Conoces a Hitler.",
	"hitler": "Eres Hitler. Ganas si llegas a Canciller tras la tercera política fascista. Ojo: los liberales quieren verte fuera.",
}

const POWER_NAME := {
	"peek": "Ojeada a políticas",
	"investigate": "Investigar lealtad",
	"special": "Llamada a elecciones extraordinarias",
	"execute": "Ejecución",
}
const POWER_SHORT := {"peek": "Ojeada", "investigate": "Investigar", "special": "Elección extra", "execute": "Ejecución"}

const RULES := """Objetivo: los liberales deben promulgar 5 políticas liberales o matar a Hitler. Los fascistas deben promulgar 6 políticas fascistas, o elegir a Hitler como Canciller tras la tercera política fascista.

Ronda: 1) el Presidente propone un Canciller. 2) Todos votan ¡Ja! o ¡Nein! y se revelan a la vez. Gana el ¡Ja! con mayoría; el empate cuenta como ¡Nein!. 3) Si gana, el Presidente roba 3 políticas, descarta 1 en secreto y pasa 2 al Canciller, que promulga una y descarta la otra. 4) Si la política promulgada da poder, el Presidente lo usa antes de la siguiente ronda.

Marcador de elecciones: si el gobierno no sale, el marcador sube. Al tercer fracaso seguido se promulga la política de arriba de la pila de robar, sin poder, y se olvidan los límites de mandato. El marcador vuelve a cero cuando se promulga una política.

Veto: tras la quinta política fascista, el Canciller puede proponer veto. Si el Presidente lo acepta, se descartan ambas políticas y cuenta como un fracaso.

Poderes: ojeada a las tres siguientes políticas; investigar lealtad (cada jugador solo una vez); llamada a elecciones extraordinarias (el Presidente elige al siguiente candidato y después la presidencia vuelve a su orden); ejecución (si es Hitler, ganan los liberales).

Límites de mandato: el Canciller anterior nunca puede repetir. El Presidente anterior tampoco, salvo que solo queden 5 jugadores vivos.

Créditos: basado en Secret Hitler (Mike Boxleiter, Tommy Maranges y Mac Schubert; Goat, Wolf & Cabbage), licencia CC BY-NC-SA 4.0. Esta versión cambia la maquetación y los textos. Uso no comercial."""

## Reglas por secciones: cada una con su color, sus puntos y un ejemplo.
const RULE_SECTIONS := [
	{
		"title": "1. Objetivo",
		"color": "#6b4f10",
		"lines": [
			"Liberales: promulgar 5 políticas liberales, o matar a Hitler.",
			"Fascistas: promulgar 6 políticas fascistas, o que Hitler llegue a Canciller tras la 3.ª política fascista.",
		],
		"example": "Ya hay 3 políticas fascistas en el tablero. Si Hitler sale elegido Canciller en una votación que gana, el equipo fascista gana al instante.",
	},
	{
		"title": "2. Equipos y reparto",
		"color": "#3b1f5c",
		"lines": [
			"Liberales: la mayoría. No saben quién es quién.",
			"Fascistas: conocen a Hitler desde el principio.",
			"Hitler: lidera el equipo fascista.",
			"Con 5 jugadores: 3 liberales, 1 fascista y Hitler.",
		],
		"example": "Partida de 5: cada jugador recibe en secreto una carta de rol. Una de ellas es Hitler, otra es Fascista y las otras tres son Liberales.",
	},
	{
		"title": "3. Preparación",
		"color": "#2d4a3e",
		"lines": [
			"Pila de robar: 6 políticas liberales y 11 fascistas, mezcladas boca abajo.",
			"El primer Presidente se elige al azar.",
			"Con 5 o 6 jugadores, Hitler sabe quién es el fascista. Con 7 a 10, no.",
		],
		"example": "Al empezar, cada jugador mira su carta en secreto. Después se entrega el marcador de Presidente al jugador elegido al azar.",
	},
	{
		"title": "4. Ronda: elegir Canciller",
		"color": "#1f5f9e",
		"lines": [
			"El Presidente propone un Canciller entre los jugadores vivos.",
			"El Canciller anterior nunca puede repetir.",
			"El Presidente anterior tampoco, salvo que solo queden 5 jugadores vivos.",
		],
		"example": "Partida de 7. El gobierno anterior fue Ana de Presidenta y Luis de Canciller. La siguiente ronda pasa a Marta, que no puede proponer a Luis, ni a Ana si Ana fue Presidenta.",
	},
	{
		"title": "5. Votación",
		"color": "#2c7a4b",
		"lines": [
			"Todos los jugadores vivos, incluidos Presidente y Canciller, votan ¡Ja! o ¡Nein!.",
			"Los votos se revelan a la vez. Gana el ¡Ja! si tiene más votos.",
			"Si hay empate, el gobierno fracasa.",
		],
		"example": "Partida de 7: 4 votan ¡Ja! y 3 ¡Nein!, el gobierno sale. Con 3 ¡Ja! y 3 ¡Nein! hay empate y fracasa.",
	},
	{
		"title": "6. Gobierno fracasado y marcador",
		"color": "#8c2f39",
		"lines": [
			"Si el gobierno fracasa, el Presidente pasa al siguiente jugador y el marcador sube 1.",
			"Al tercer fracaso seguido se promulga la política de arriba de la pila de robar, sin votación y sin poder.",
			"El marcador vuelve a 0 cada vez que se promulga una política.",
		],
		"example": "Fracaso 1: marcador en 1. Fracaso 2: marcador en 2. Fracaso 3: se promulga la primera carta del mazo y el marcador vuelve a 0.",
	},
	{
		"title": "7. Sesión legislativa",
		"color": "#a35c1e",
		"lines": [
			"El Presidente roba 3 políticas, las mira en secreto y descarta 1 boca abajo.",
			"Pasa las 2 restantes al Canciller, que mira en secreto, descarta 1 y promulga la otra.",
			"Durante la sesión no se puede hablar ni hacer señas.",
		],
		"example": "El Presidente roba liberal, fascista y fascista. Descarta un fascista y pasa liberal y fascista. El Canciller descarta el fascista y promulga la liberal.",
	},
	{
		"title": "8. Poderes de las políticas fascistas",
		"color": "#7a1f1f",
		"lines": [
			"Una política fascista da poder solo si la casilla que cubre lo tiene impreso.",
			"Ojeada: mirar las 3 próximas políticas del mazo, sin cambiar el orden.",
			"Investigar lealtad: ver el carné de partido de un jugador (su bando, no su rol). Solo una vez por jugador.",
			"Elección extraordinaria: elegir al siguiente Presidente. Después la rotación sigue su curso.",
			"Ejecución: eliminar a un jugador. Si es Hitler, ganan los liberales.",
			"El poder se usa una sola vez y el Presidente decide cómo.",
		],
		"example": "Partida de 7: la 2.ª política fascista da Investigar. El Presidente audita a Marta y ve que es Liberal. Puede contarlo o mentir.",
	},
	{
		"title": "9. Veto",
		"color": "#4a1a5c",
		"lines": [
			"Tras la 5.ª política fascista, el Canciller puede proponer veto en lugar de promulgar.",
			"Si el Presidente acepta, se descartan las 2 políticas y el marcador sube 1.",
			"Si lo rechaza, el Canciller debe promulgar una de las dos.",
		],
		"example": "El Canciller propone veto. El Presidente acepta: ambas cartas van al descarte y el marcador pasa a 1.",
	},
	{
		"title": "10. Consejos",
		"color": "#2e4057",
		"lines": [
			"Lo que sabes en secreto (investigaciones, cartas vistas) lo puedes contar o mentir.",
			"Hitler solo está obligado a decir la verdad si lo asesinan o si llega a Canciller tras 3 fascistas.",
			"Los fascistas ganan sobre todo eligiendo a Hitler como Canciller.",
		],
		"example": "Un liberal investiga a Marta, que es Fascista, y dice que es Liberal. Mentir sobre lo que se sabe en secreto está permitido.",
	},
	{
		"title": "Créditos",
		"color": "#333333",
		"lines": [
			"Basado en Secret Hitler (Mike Boxleiter, Tommy Maranges y Mac Schubert; Goat, Wolf & Cabbage), licencia CC BY-NC-SA 4.0. Uso no comercial.",
		],
	},
]
