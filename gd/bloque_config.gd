# bloque_config.gd
class_name BloqueConfig
extends HBoxContainer

var grupo: String
var clave: String
var _control: Control

func setup(g: String, k: String) -> void:
	grupo = g
	clave = k
	var actual = ManagerConfig.get_valor(g, k)

	var nombre := Label.new()
	nombre.text = k.replace("_", " ")
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ManagerConfig.estilizar_label(nombre, "textos")
	
	add_child(nombre)

	if actual is Color:
		var cp := ColorPickerButton.new()
		cp.color = actual
		cp.custom_minimum_size = Vector2(90, 40)
		cp.color_changed.connect(func(c): ManagerConfig.set_valor(grupo, clave, c))
		_control = cp
	else:
		var le := LineEdit.new()
		le.text = str(actual)
		le.custom_minimum_size.x = 90
		le.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		le.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
		le.text_submitted.connect(_enviar.bind(le))
		le.focus_exited.connect(func(): _enviar(le.text, le))
		_control = le
	add_child(_control)
	ManagerConfig.config_cambiada.connect(_on_cambio)

func _enviar(texto: String, le: LineEdit) -> void:
	var t := texto.strip_edges().replace(",", ".")
	if t.is_valid_float():
		ManagerConfig.set_valor(grupo, clave, t.to_float())
	le.text = str(ManagerConfig.get_valor(grupo, clave))   # muestra el valor ya limitado

func _on_cambio(g: String, k: String) -> void:
	if g != grupo or k != clave:
		return
	var v = ManagerConfig.get_valor(g, k)
	if _control is ColorPickerButton:
		_control.color = v
	elif not _control.has_focus():
		_control.text = str(v)
