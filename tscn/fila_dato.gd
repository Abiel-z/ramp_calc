class_name FilaDato
extends HBoxContainer

signal valor_editado(campo: String, valor: float)

@export var campo := ""
@export var nombre := ""
@export var editable := true   # false = el LineEdit solo muestra el valor
@export var decimales := 1
@export var es_longitud := true 

var _ultimo := 0.0
var _error: IndicadorError

@onready var label_nombre: Label = $nombre
@onready var _entrada: LineEdit = $entrada
@onready var icono_error: TextureRect = $entrada/icono_error

func _ready() -> void:
	label_nombre.text = nombre
	_entrada.editable = editable
	ManagerConfig.estilizar_label(label_nombre, "textos")
	ManagerConfig.estilizar_label(_entrada, "ingreso")
	# que el estado no editable se vea igual que el normal
	_entrada.add_theme_stylebox_override("read_only", _entrada.get_theme_stylebox("normal"))
	_entrada.add_theme_color_override("font_uneditable_color", _entrada.get_theme_color("font_color"))

	# el indicador se crea DESPUÉS de estilizar, para guardar el estilo ya aplicado
	_error = IndicadorError.new(_entrada, icono_error)

	_entrada.text_submitted.connect(func(_t): _entrada.release_focus())
	_entrada.focus_entered.connect(_error.limpiar)
	_entrada.focus_exited.connect(_confirmar)
	Ajustes.unidad_cambiada.connect(_on_unidad_cambiada)
	_refrescar_nombre()


func _refrescar_nombre() -> void:
	label_nombre.text = "%s (%s)" % [nombre, Unidades.actual()] if es_longitud else nombre
	
func _on_unidad_cambiada() -> void:
	_refrescar_nombre()
	_entrada.text = _fmt(_ultimo)

func _a_pantalla(v: float) -> float:
	return Unidades.de_cm(v) if es_longitud else v

func _dec() -> int:
	return Unidades.decimales() if es_longitud else decimales


# no pisa el campo mientras se está escribiendo
func actualizar(valor: float) -> void:
	_ultimo = valor
	if not _entrada.has_focus():
		_entrada.text = _fmt(valor)

func marcar_error(color: Color) -> void:
	_error.mostrar(color)

func _confirmar() -> void:
	var t := _entrada.text.strip_edges()
	if t.is_empty():
		_entrada.text = _fmt(_ultimo)
		return
	var s := t.replace(",", ".")
	if not s.is_valid_float():
		_entrada.text = _fmt(_ultimo)
		marcar_error(ManagerConfig.get_color("resultado", "error_color"))
		return
	var v := s.to_float()   # viene en la unidad visible
	# comparar redondeado a lo que se ve, para que tocar el campo sin cambiarlo no mueva el valor
	var paso := pow(10.0, -_dec())
	if is_equal_approx(snappedf(v, paso), snappedf(_a_pantalla(_ultimo), paso)):
		_entrada.text = _fmt(_ultimo)
		return
	valor_editado.emit(campo, Unidades.a_cm(v) if es_longitud else v)

func _fmt(v: float) -> String:
	var s := str(snappedf(_a_pantalla(v), pow(10.0, -_dec())))
	return s.trim_suffix(".0").replace(".", ",")
