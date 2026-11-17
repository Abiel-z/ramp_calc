class_name BloqueInformacion
extends PanelContainer

signal tocado(id: String)
signal valor_editado(id: String, campo: String, valor: float)
signal eliminar_solicitado(id: String)


const CLAVE_LIMITE := {
	"largo": "largo", "ancho": "ancho", "pendiente": "pendiente",
	"desnivel": "altura",
	"altura": "cota", "alt_min": "cota", "alt_max": "cota",
}
var _ultimos := {}   # campo -> último valor válido

const BORDE := Color(0.5, 0.5, 0.5, 0.6)

var id := ""
var _filas := {}   # campo -> FilaDato
var _press := Vector2.ZERO
var _tap_valido := false

@onready var label_titulo: Label = $v_box/encabezado/titulo
@onready var _boton_eliminar: Button = $v_box/encabezado/boton_eliminar
@onready var _cols: Array[VBoxContainer] = [$v_box/contenido/fila_1, $v_box/contenido/fila_2]
@onready var contenido : HBoxContainer = $v_box/contenido

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_stylebox_override("panel", _estilo(BORDE, 1))
	ManagerConfig.estilizar_label(label_titulo, "titulo")
	_boton_eliminar.pressed.connect(func(): eliminar_solicitado.emit(id))
	_recolectar_filas(contenido)

func _recolectar_filas(nodo: Node) -> void:
	for h in nodo.get_children():
		if h is FilaDato:
			_filas[h.campo] = h
			h.valor_editado.connect(_on_valor_editado)
		else:
			_recolectar_filas(h)


func cargar(e, varios_cuerpos := false) -> void:
	id = e.id
	label_titulo.text = e.id.replace("_", " ").capitalize()
	actualizar(e, varios_cuerpos)

func actualizar(e, varios_cuerpos := false) -> void:
	_boton_eliminar.visible = e.tipo == "rampa"
	var v := _valores(e, varios_cuerpos)   # solo los campos que corresponden a este elemento
	for campo in _filas:
		var fila: FilaDato = _filas[campo]
		fila.visible = v.has(campo)
		if v.has(campo):
			fila.actualizar(v[campo])
			_ultimos[campo] = v[campo]
	for col in _cols:
		col.visible = col.get_children().any(func(c): return c.visible)

func _valores(e, varios_cuerpos: bool) -> Dictionary:
	var dz: float = absf(e.cota_fin - e.cota_inicio)
	var v := {"largo": e.largo, "ancho": e.ancho}
	if e.tipo == "rampa":
		v["pendiente"] = dz / e.largo * 100.0 if e.largo > 0.0 else 0.0
		v["desnivel"] = dz
		if varios_cuerpos:   # solo cuando el plan tiene más de una rampa
			v["alt_min"] = minf(e.cota_inicio, e.cota_fin)
			v["alt_max"] = maxf(e.cota_inicio, e.cota_fin)
		v["altura"] = e.cota_inicio
	return v

func _on_valor_editado(campo: String, valor: float) -> void:
	var clave: String = CLAVE_LIMITE.get(campo, "")
	if clave != "" and not RampaCalculo.en_rango(clave, valor):
		if _ultimos.has(campo):
			_filas[campo].actualizar(_ultimos[campo])
		_filas[campo].marcar_error(ManagerConfig.get_color("global", "error_color"))
		return
	_ultimos[campo] = valor
	valor_editado.emit(id, campo, valor)

func resaltar(activo: bool) -> void:
	var color := ManagerConfig.get_color("seleccion", "color") if activo else BORDE
	add_theme_stylebox_override("panel", _estilo(color, 3 if activo else 1))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press = event.global_position
			_tap_valido = true
		else:
			if _tap_valido and event.global_position.distance_to(_press) < 12.0:
				tocado.emit(id)
			_tap_valido = false
	elif event is InputEventMouseMotion and _tap_valido:
		if event.global_position.distance_to(_press) > 12.0:
			_tap_valido = false

func _fmt(v: float) -> String:
	var s := str(snappedf(v, 0.1))
	return s.trim_suffix(".0").replace(".", ",")

func _estilo(borde: Color, ancho: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = borde
	sb.set_border_width_all(ancho)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	return sb
