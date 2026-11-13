# bloque_informacion.gd
class_name BloqueInformacion
extends PanelContainer

signal tocado(id: String)
signal valor_editado(id: String, campo: String, valor: float)

const POR_COLUMNA := 3
const BORDE := Color(0.5, 0.5, 0.5, 0.6)

var id := ""
var _titulo: Label
var _cols: Array[GridContainer] = []
var _inputs := {}    # campo -> LineEdit
var _labels := {}    # campo -> Label (solo lectura)
var _ultimos := {}   # campo -> último valor que vino del plan
var _press := Vector2.ZERO
var _tap_valido := false

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_stylebox_override("panel", _estilo(BORDE, 1))

	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(caja)

	_titulo = Label.new()
	caja.add_child(_titulo)
	ManagerConfig.estilizar_label(_titulo, "titulo")

	var columnas := HBoxContainer.new()
	columnas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columnas.add_theme_constant_override("separation", 24)
	caja.add_child(columnas)

	for i in 2:
		var g := GridContainer.new()
		g.columns = 2
		g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_theme_constant_override("h_separation", 12)
		g.add_theme_constant_override("v_separation", 2)
		columnas.add_child(g)
		_cols.append(g)

func cargar(seg_id: String, titulo: String, filas: Array) -> void:
	id = seg_id
	_titulo.text = titulo
	for i in filas.size():
		var f: Dictionary = filas[i]
		var g := _cols[0] if i < POR_COLUMNA else _cols[1]
		_ultimos[f.campo] = f.valor

		var n := Label.new()
		n.text = f.nombre
		g.add_child(n)
		ManagerConfig.estilizar_label(n, "textos")

		if f.editable:
			var le := LineEdit.new()
			le.text = _fmt(f.valor)
			le.alignment = HORIZONTAL_ALIGNMENT_RIGHT
			le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			le.custom_minimum_size.x = 70
			le.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
			le.text_submitted.connect(func(_t): le.release_focus())   # Enter = soltar el foco = confirmar
			le.focus_exited.connect(_confirmar.bind(f.campo))
			g.add_child(le)
			ManagerConfig.estilizar_label(le, "ingreso")
			_inputs[f.campo] = le
		else:
			var v := Label.new()
			v.text = _fmt(f.valor)
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			g.add_child(v)
			ManagerConfig.estilizar_label(v, "textos")
			_labels[f.campo] = v
	_cols[1].visible = _cols[1].get_child_count() > 0

# refresca los valores sin reconstruir nada (no pisa el campo que se está escribiendo)
func actualizar(filas: Array) -> void:
	for f in filas:
		_ultimos[f.campo] = f.valor
		if _inputs.has(f.campo):
			var le: LineEdit = _inputs[f.campo]
			if not le.has_focus():
				le.text = _fmt(f.valor)
		elif _labels.has(f.campo):
			_labels[f.campo].text = _fmt(f.valor)

func _confirmar(campo: String) -> void:
	var le: LineEdit = _inputs[campo]
	var t := le.text.strip_edges()
	if t == _fmt(_ultimos[campo]):
		return   # no se tocó nada
	var s := t.replace(",", ".")
	if not s.is_valid_float():
		le.text = _fmt(_ultimos[campo])
		return
	valor_editado.emit(id, campo, s.to_float())

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
