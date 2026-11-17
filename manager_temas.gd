# manager_temas.gd (autoload)
extends Node

signal tema_cambiado

# ====== AQUÍ VAN LAS UBICACIONES DE TUS .tres ======
const RUTAS := {
	"button_normal": "res://stylebox/button_hover.tres",
	"button_hover": "res://stylebox/button_normal.tres",
	"button_pressed": "res://stylebox/button_pressed.tres",
	"ingreso_normal": "res://stylebox/ingreso_normal.tres",
	"ingreso_focus": "res://stylebox/ingreso_focus.tres",
	"ingreso_read_only": "res://stylebox/ingreso_read_only.tres",
	"paneles_fondo_blanco": "res://stylebox/paneles_fondo_blanco.tres",
	"paneles_sin_fondo": "res://stylebox/paneles_sin_fondo.tres",
	"label_sin_fondo": "res://stylebox/label_sin_fondo.tres",
}

# Cómo se pinta cada uno: [fuente, opacidad]. Fuente = "tinte" o "fondo".
# bg = null: no se toca el relleno (el de "sin fondo" es transparente).
# Las opacidades son de ejemplo: ajústalas mirando el resultado.
const REGLAS := {
	"button_normal": {"bg": ["tinte", 0.45], "borde": ["tinte", 0.9]},
	"button_hover": {"bg": ["tinte", 0.6], "borde": ["tinte", 1.0]},
	"button_pressed": {"bg": ["tinte", 0.85], "borde": ["tinte", 1.0]},
	"ingreso_normal": {"bg": ["fondo"], "borde": ["tinte", 0.6]},
	"ingreso_focus": {"bg": ["fondo"], "borde": ["tinte", 1.0]},
	"ingreso_read_only": {"bg": ["tinte", 0.08], "borde": ["tinte", 0.3]},
	"paneles_fondo_blanco": {"bg": ["fondo"], "borde": ["tinte", 0.9]},
	"paneles_sin_fondo": {"bg": null, "borde": ["tinte", 0.9]},
	"label_sin_fondo": {"bg": null, "borde": ["tinte", 0.8]},
}

# tinte/fondo null = restaurar los colores originales del inspector
const TEMAS := {
	"claro":   {"premium": false, "muestra": Color("ffffff"), "fondo": null, "tinte": null},
	"rosa":    {"premium": true,  "muestra": Color("ff8fb8"), "fondo": Color("fffafc"), "tinte": Color("ff8fb8")},
	"menta":   {"premium": true,  "muestra": Color("5fcfa6"), "fondo": Color("f9fffc"), "tinte": Color("5fcfa6")},
	"lavanda": {"premium": true,  "muestra": Color("a78bfa"), "fondo": Color("fbf9ff"), "tinte": Color("a78bfa")},
	"azul":    {"premium": true,  "muestra": Color("8dceff"), "fondo": Color("fbf9ff"), "tinte": Color("8dceff")},
}

var es_pago := false      # TODO: lo pondrá Play Billing; por ahora, manual
var tema_actual := "claro"

var _estilos := {}        # clave -> StyleBoxFlat
var _originales := {}     # clave -> [bg, borde] tal como están en el inspector

func _ready() -> void:
	for clave in RUTAS:
		var sb := load(RUTAS[clave]) as StyleBoxFlat
		if sb == null:
			push_warning("manager_temas: no encontré '%s' (%s)" % [clave, RUTAS[clave]])
			continue
		_estilos[clave] = sb
		_originales[clave] = [sb.bg_color, sb.border_color]
	var guardado := _leer_guardado()
	set_tema(guardado if puede_usar(guardado) else "claro")

func puede_usar(id: String) -> bool:
	return TEMAS.has(id) and (not TEMAS[id]["premium"] or es_pago)

func set_tema(id: String) -> bool:
	if not puede_usar(id):
		return false          # la interfaz decide qué mostrar (candado / apoyar)
	tema_actual = id
	aplicar_tema(id)
	_guardar(id)
	return true

func aplicar_tema(id: String) -> void:
	var t: Dictionary = TEMAS[id]
	for clave in _estilos:
		var sb: StyleBoxFlat = _estilos[clave]
		if t["tinte"] == null:
			sb.bg_color = _originales[clave][0]
			sb.border_color = _originales[clave][1]
			continue
		var regla: Dictionary = REGLAS[clave]
		if regla["bg"] != null:
			sb.bg_color = _resolver(regla["bg"], t)
		sb.border_color = _resolver(regla["borde"], t)
	tema_cambiado.emit()

func _resolver(r: Array, t: Dictionary) -> Color:
	if r[0] == "fondo":
		return t["fondo"]
	return Color(t["tinte"], r[1])

# para que otros scripts (3D, iconos) lean el tema sin duplicar colores
func tinte_actual() -> Color:
	var t = TEMAS[tema_actual]["tinte"]
	return t if t != null else _originales.get("button_normal", [Color.WHITE, Color.WHITE])[1]

func _leer_guardado() -> String:
	return Ajustes.obtener("apariencia", "tema")

func _guardar(id: String) -> void:
	Ajustes.guardar("apariencia", "tema", id)


# rol: "titulo", "texto" o "fondo". En el tema claro devuelve el defecto
# (el que ya tienes en manager_config), así no duplicas colores.
func color_rol(rol: String, defecto: Color) -> Color:
	var t: Dictionary = TEMAS[tema_actual]
	if t["tinte"] == null:
		return defecto
	match rol:
		"titulo": return t.get("titulo", t["tinte"].darkened(0.55))
		"texto":  return t.get("texto",  t["tinte"].darkened(0.75))
		"fondo":  return t["fondo"]
	return defecto
