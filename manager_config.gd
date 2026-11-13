extends Node

signal config_cambiada(grupo: String, clave: String)

const DEFAULTS := {
	"titulo": {
		"text_size": {"valor": 25.0, "min": 10.0, "max": 60.0},
		"text_color": {"valor": Color.MIDNIGHT_BLUE},
	},
	"textos" : {
		"text_size": {"valor": 20.0, "min": 10.0, "max": 60.0},
		"text_color": {"valor": Color.BLACK},
	},
	"cotas": {
		"text_size": {"valor": 16.0, "min": 8.0, "max": 48.0},
		"grosor_linea": {"valor": 1.0, "min": 1.0, "max": 10.0},
		"contorno_texto": {"valor": 2.0, "min": 0.0, "max": 8.0},
		"text_color": {"valor": Color.BLACK},
		"color_contorno": {"valor": Color.WHITE},
	},
	"global": {
		"error_color": {"valor": Color.BLACK},
	},
	"ingreso": {
		"text_size": {"valor": 18.0, "min": 10.0, "max": 48.0},
		"text_color": {"valor": Color.BLACK},
	},
	"resultado": {
		"text_size": {"valor": 18.0, "min": 10.0, "max": 48.0},
		"text_color": {"valor": Color.BLACK},
	},
	"contorno": {
		"grosor": {"valor": 1.0, "min": 0.5, "max": 1.5},
		"umbral": {"valor": 0.3, "min": 0.01, "max": 2.0},
		"color_linea": {"valor": Color(0.0, 0.0, 0.0, 1.0)},
		"color_fondo": {"valor": Color(1.0, 1.0, 1.0, 1.0)},
		"fondo_3d": {"valor": Color(0.106, 0.125, 0.188, 1.0)},
	},
	"seleccion": {
	"color": {"valor": Color("#2f7bff")},
	"grosor": {"valor": 3.0, "min": 1.0, "max": 10.0},
	},
}

var _valores: Dictionary = {}

func _ready() -> void:
	for g in DEFAULTS:
		_valores[g] = {}
		for k in DEFAULTS[g]:
			_valores[g][k] = DEFAULTS[g][k]["valor"]

func get_valor(grupo: String, clave: String) -> Variant:
	if not (_valores.has(grupo) and _valores[grupo].has(clave)):
		push_error("Config inexistente: %s/%s" % [grupo, clave])
		return null
	return _valores[grupo][clave]

func get_color(grupo: String, clave: String = "text_color") -> Color:
	return get_valor(grupo, clave)

func get_size(grupo: String, clave: String = "text_size") -> float:
	return get_valor(grupo, clave)

func set_valor(grupo: String, clave: String, v: Variant) -> void:
	print("set_valor ", grupo, "/", clave, " = ", v)   # temporal
	if get_valor(grupo, clave) == null:
		return
	var def: Dictionary = DEFAULTS[grupo][clave]
	if v is float:
		v = clampf(v, def.get("min", -INF), def.get("max", INF))
	if _valores[grupo][clave] == v:
		return   # sin cambios: no emitir (evita bucles y señales de más)
	_valores[grupo][clave] = v
	config_cambiada.emit(grupo, clave)

func reset() -> void:
	for g in DEFAULTS:
		for k in DEFAULTS[g]:
			set_valor(g, k, DEFAULTS[g][k]["valor"])
			
func estilizar_label(control: Control, grupo: String) -> void:
	if not _valores.has(grupo):
		push_error("Grupo de config inexistente: %s" % grupo)
		return
	_aplicar_estilo(control, grupo)
	var cb := func(g: String, _k: String) -> void:
		if g == grupo and is_instance_valid(control):
			_aplicar_estilo(control, grupo)
	config_cambiada.connect(cb)
	control.tree_exited.connect(
		func(): config_cambiada.disconnect(cb),
		CONNECT_ONE_SHOT
	)

func _aplicar_estilo(control: Control, grupo: String) -> void:
	if _valores[grupo].has("text_size"):
		control.add_theme_font_size_override("font_size", int(get_size(grupo)))
	if _valores[grupo].has("text_color"):
		control.add_theme_color_override("font_color", get_color(grupo))
		
func vincular_shader(material: ShaderMaterial, grupo: String) -> void:
	if not _valores.has(grupo):
		push_error("Grupo de config inexistente: %s" % grupo)
		print("Grupo de config inexistente")
		return
	
	for k in _valores[grupo]:
		material.set_shader_parameter(k, _valores[grupo][k])
	config_cambiada.connect(func(g: String, k: String) -> void:
		if g == grupo:
			print("aplicando al shader ", k, " = ", _valores[g][k])   # temporal
			material.set_shader_parameter(k, _valores[g][k])
	)
