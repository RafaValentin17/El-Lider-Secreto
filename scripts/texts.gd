class_name Txt
extends RefCounted
## Textos de la interfaz con los nombres del juego original (version en espanol).

const TITLE := "La Corona Real"
const LIB := "Libertador"
const FAS := "Tirano"
const HIT := "El Esclavista"
const PRES := "Rey"
const CHAN := "Consejero"
const LIB_POL := "Política libertadora"
const FAS_POL := "Política tiránica"
const TRACK := "Marcador de elecciones"
const DRAW := "Pila de robar"
const DISCARD := "Pila de descarte"
const JA := "SÍ"
const NEIN := "NO"

const ROLE_NAME := {"liberal": "LIBERTADOR", "fascist": "TIRANO", "hitler": "EL ESCLAVISTA"}
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

Límites de mandato: el Consejero anterior nunca puede volver a ser Consejero. En partidas de 7 o más jugadores, el Rey anterior tampoco puede ser Consejero.

Créditos: basado en Secret Hitler (Mike Boxleiter, Tommy Maranges y Mac Schubert; Goat, Wolf & Cabbage), licencia CC BY-NC-SA 4.0. Esta versión cambia la maquetación y los textos. Uso no comercial."""

## Reglas por secciones: cada una con su color, sus puntos y un ejemplo.
const RULE_SECTIONS := [
	{
		"title": "1. Equipos",
		"color": "#3b1f5c",
		"text": """[color=#4aa3ff]LIBERTADORES[/color]: son la mayoría y no conocen el rol de los demás jugadores.
[color=#e0463c]TIRANOS[/color]: son la minoría y se conocen entre ellos.
[color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color]: forma parte de [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color], con estas peculiaridades:
  – Cuenta como [color=#e0463c]TIRANO[/color] a efectos de investigación.
  – Con 5 o 6 jugadores sabe quiénes son [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color], y estos le conocen.
  – A partir de 7 jugadores no sabe quiénes son [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color], pero estos sí le conocen a él.

Reparto con 5 o 6 jugadores:
5 jugadores: 3 [color=#4aa3ff]LIBERTADORES[/color], 1 [color=#e0463c]TIRANO[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].
6 jugadores: 4 [color=#4aa3ff]LIBERTADORES[/color], 1 [color=#e0463c]TIRANO[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].

Reparto de 7 a 10 jugadores:
7 jugadores: 4 [color=#4aa3ff]LIBERTADORES[/color], 2 [color=#e0463c]TIRANOS[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].
8 jugadores: 5 [color=#4aa3ff]LIBERTADORES[/color], 2 [color=#e0463c]TIRANOS[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].
9 jugadores: 5 [color=#4aa3ff]LIBERTADORES[/color], 3 [color=#e0463c]TIRANOS[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].
10 jugadores: 6 [color=#4aa3ff]LIBERTADORES[/color], 3 [color=#e0463c]TIRANOS[/color] y [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].

Ejemplo: en una partida de 5, los 5 jugadores reciben su carta en secreto. Una será [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color], otra [color=#e0463c]TIRANO[/color] y las otras tres [color=#4aa3ff]LIBERTADORES[/color].""",
	},
	{
		"title": "2. Objetivo",
		"color": "#6b4f10",
		"text": """[color=#4aa3ff]LIBERTADORES[/color]: aprobar 5 [color=#9fd8ff]LEYES[/color] [color=#9fd8ff]LIBERTADORAS[/color] o ejecutar a [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color].
[color=#e0463c]TIRANOS[/color]: aprobar 6 [color=#ff8a80]LEYES[/color] [color=#ff8a80]TIRÁNICAS[/color], o conseguir que [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color] salga elegido [color=#b388ff]CONSEJERO[/color] tras tener 3 [color=#ff8a80]LEYES[/color] [color=#ff8a80]TIRÁNICAS[/color] aprobadas.

Ejemplo: con 3 [color=#ff8a80]LEYES[/color] [color=#ff8a80]TIRÁNICAS[/color] ya aprobadas, [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] propone a [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color] como [color=#b388ff]CONSEJERO[/color]. Si el gobierno es aprobado, [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color] ganan al instante.""",
	},
	{
		"title": "3. Preparación",
		"color": "#2d4a3e",
		"text": """[color=#4dd0c8]El[/color] [color=#4dd0c8]MAZO[/color] de [color=#e6e6e6]LEYES[/color] se compone de 6 [color=#9fd8ff]LEYES[/color] [color=#9fd8ff]LIBERTADORAS[/color] y 11 [color=#ff8a80]LEYES[/color] [color=#ff8a80]TIRÁNICAS[/color], mezcladas boca abajo.
El primer [color=#ff9f43]REY[/color] se elige al azar. Después, el cargo pasa por orden en cada ronda.

Ejemplo: en una partida de 5, el primer [color=#ff9f43]REY[/color] sale al azar entre los 5 jugadores. La siguiente ronda pasa al jugador siguiente en el orden.""",
	},
	{
		"title": "4. Dinámica de ronda",
		"color": "#1f5f9e",
		"text": """[color=#ff9f43]El[/color] [color=#ff9f43]REY[/color] propone a un [color=#b388ff]CONSEJERO[/color].
Todos los jugadores vivos, incluidos [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] y [color=#b388ff]el[/color] [color=#b388ff]CONSEJERO[/color] propuesto, votan en secreto [color=#3fbf6a]SÍ[/color] o [color=#ff5c8a]NO[/color].
Se necesita mayoría simple de [color=#3fbf6a]SÍ[/color]. Si gana [color=#ff5c8a]el[/color] [color=#ff5c8a]NO[/color] o hay empate, el gobierno fracasa y el marcador de fracasos sube 1.
Si el gobierno es aprobado, [color=#b388ff]el[/color] [color=#b388ff]CONSEJERO[/color] nunca podrá volver a serlo. En partidas de 7 o más jugadores, [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] de esa ronda tampoco podrá serlo en la siguiente.
Al tercer fracaso seguido, se promulga automáticamente [color=#e6e6e6]la[/color] [color=#e6e6e6]LEY[/color] de arriba del [color=#4dd0c8]MAZO[/color], sin votación.

Ejemplo de mayoría: 5 jugadores (Ana, Luis, Marta, Pablo y Lucía). Ana, [color=#ff9f43]REY[/color], propone a Luis. Votan: Ana [color=#3fbf6a]SÍ[/color], Luis [color=#3fbf6a]SÍ[/color], Marta [color=#ff5c8a]NO[/color], Pablo [color=#3fbf6a]SÍ[/color] y Lucía [color=#ff5c8a]NO[/color]. Son 3 [color=#3fbf6a]SÍ[/color] frente a 2 [color=#ff5c8a]NO[/color]: el gobierno queda aprobado. Ana no puede ser [color=#b388ff]CONSEJERA[/color] en la siguiente ronda.

Ejemplo de empate: 6 jugadores, 3 [color=#3fbf6a]SÍ[/color] y 3 [color=#ff5c8a]NO[/color]. El gobierno fracasa y el marcador sube 1.""",
	},
	{
		"title": "5. Sesión legislativa y ejecutiva",
		"color": "#a35c1e",
		"text": """[color=#ff9f43]El[/color] [color=#ff9f43]REY[/color] roba 3 [color=#e6e6e6]LEYES[/color] y las mira en secreto. Descarta una y pasa las otras dos al [color=#b388ff]CONSEJERO[/color].
[color=#b388ff]El[/color] [color=#b388ff]CONSEJERO[/color] elige una de esas dos [color=#e6e6e6]LEYES[/color] para promulgarla. Suma 1 punto al marcador de [color=#4aa3ff]LIBERTADORES[/color] si es blanca, o al de [color=#e0463c]TIRANOS[/color] si es negra.
Durante la sesión, [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] y [color=#b388ff]el[/color] [color=#b388ff]CONSEJERO[/color] no pueden hablar ni hacer señas.

Ejemplo: [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] roba [color=#9fd8ff]LIBERTADORA[/color], [color=#ff8a80]TIRÁNICA[/color] y [color=#ff8a80]TIRÁNICA[/color]. Descarta una [color=#ff8a80]TIRÁNICA[/color] y pasa [color=#9fd8ff]la[/color] [color=#9fd8ff]LIBERTADORA[/color] y la otra [color=#ff8a80]TIRÁNICA[/color] al [color=#b388ff]CONSEJERO[/color]. Este elige [color=#ff8a80]la[/color] [color=#ff8a80]TIRÁNICA[/color] y se promulga: suma 1 punto a [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color].""",
	},
	{
		"title": "6. Poderes tiránicos",
		"color": "#7a1f1f",
		"text": """Se activan una vez por partida, cuando se promulga una [color=#e6e6e6]LEY[/color] [color=#ff8a80]TIRÁNICA[/color] que cubre una casilla con poder. Los usa [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] actual justo después de promulgar la ley, antes de iniciar la siguiente ronda con el nuevo [color=#ff9f43]REY[/color].
Ojeada: mira en privado las 3 próximas [color=#e6e6e6]LEYES[/color], sin cambiar su orden.
Investigar lealtad: elige a un jugador y mira en privado su equipo ([color=#4aa3ff]LIBERTADORES[/color] o [color=#e0463c]TIRANOS[/color]).
Elección extraordinaria: [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] anuncia en público quién será su sucesor en la siguiente ronda.
Ejecución: [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] ejecuta a un jugador. Si es [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color], [color=#4aa3ff]los[/color] [color=#4aa3ff]LIBERTADORES[/color] ganan la partida automáticamente. Si es otro rol, este no será revelado.

Ejemplo de ejecución: [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] ejecuta a Pablo. Si Pablo es [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color], ganan [color=#4aa3ff]los[/color] [color=#4aa3ff]LIBERTADORES[/color]. Si es un [color=#e0463c]TIRANO[/color], su rol no se revela.""",
	},
	{
		"title": "7. Veto y consejos",
		"color": "#4a1a5c",
		"text": """Veto: tras la 5.ª [color=#e6e6e6]LEY[/color] [color=#ff8a80]TIRÁNICA[/color], [color=#b388ff]el[/color] [color=#b388ff]CONSEJERO[/color] puede proponer un [color=#ffe082]VETO[/color] en lugar de promulgar una [color=#e6e6e6]LEY[/color]. Si [color=#ff9f43]el[/color] [color=#ff9f43]REY[/color] lo acepta, se descartan ambas [color=#e6e6e6]LEYES[/color] y el marcador de fracasos sube 1. Si lo rechaza, [color=#b388ff]el[/color] [color=#b388ff]CONSEJERO[/color] debe promulgar una de ellas.

Toda la información que tengas puedes contarla o mentir según te convenga.
[color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color] solo está obligado a decir la verdad si es ejecutado o elegido [color=#b388ff]CONSEJERO[/color] tras la tercera [color=#e6e6e6]LEY[/color] [color=#ff8a80]TIRÁNICA[/color].
La forma más fácil de que ganen [color=#e0463c]los[/color] [color=#e0463c]TIRANOS[/color] es elegir a [color=#d4af37]EL[/color] [color=#d4af37]ESCLAVISTA[/color] como [color=#b388ff]CONSEJERO[/color] para que promulgue [color=#ff8a80]LEYES[/color] [color=#ff8a80]TIRÁNICAS[/color].""",
	},
]
