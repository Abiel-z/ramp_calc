class_name IndicadorError
extends RefCounted

var _campo: LineEdit
var _icono: TextureRect
var _sb_base: StyleBox
var _version := 0

func _init(campo: LineEdit, icono: TextureRect) -> void:
	_campo = campo
	_icono = icono
	_icono.visible = false
	_icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# guardar el estilo YA estilizado, para poder volver exactamente a él
	_sb_base = campo.get_theme_stylebox("normal")

func mostrar(color: Color, segundos := 0.8) -> void:
	print("mostrar() llamado, color=", color, " campo valido=", is_instance_valid(_campo))
	if not is_instance_valid(_campo):
		return
	_icono.modulate = color
	_icono.visible = true
	var sb := _sb_base.duplicate() as StyleBoxFlat
	if sb:
		sb.border_color = color
		sb.set_border_width_all(2)
		sb.bg_color = Color(color.r, color.g, color.b, 0.15)
		_campo.add_theme_stylebox_override("normal", sb)
	if segundos > 0.0:
		_version += 1
		var v := _version
		await _campo.get_tree().create_timer(segundos).timeout
		if v == _version and is_instance_valid(_campo):
			limpiar()

func limpiar() -> void:
	if not is_instance_valid(_campo):
		return
	_icono.visible = false
	_campo.add_theme_stylebox_override("normal", _sb_base)
