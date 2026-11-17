class_name FilaColor
extends VBoxContainer

signal valor_editado(campo: String, valor: Color)

const TAM := 40

@export var campo := ""
@export var nombre := ""

var _actual := Color.WHITE
var _botones := {}   # Button -> Color

@onready var _nombre: Label = $nombre
@onready var _muestras: HFlowContainer = $muestras

func _ready() -> void:
	_nombre.text = nombre
	ManagerConfig.estilizar_label(_nombre, "textos")
	#for n in ManagerConfig.PALETA:
		#var c: Color = ManagerConfig.PALETA[n]
		#var b := Button.new()
		#b.custom_minimum_size = Vector2(TAM, TAM)
		#b.focus_mode = Control.FOCUS_NONE
		#b.pressed.connect(_elegir.bind(c))
		#_muestras.add_child(b)
		#_botones[b] = c
	#_marcar()

func actualizar(valor: Color) -> void:
	_actual = valor
	_marcar()

func _elegir(c: Color) -> void:
	_actual = c
	_marcar()
	valor_editado.emit(campo, c)

func _marcar() -> void:
	for b in _botones:
		var c: Color = _botones[b]
		var sb := _estilo(c, c.is_equal_approx(_actual))
		for st in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(st, sb)

func _estilo(c: Color, elegido: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(8)
	sb.border_color = Color.WHITE
	sb.set_border_width_all(4 if elegido else 0)
	return sb
