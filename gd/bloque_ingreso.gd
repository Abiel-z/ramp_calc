class_name BloqueIngreso
extends VBoxContainer

signal cambio

@export var nombre: String = ""
@export var unidad: String = ""

@onready var titulo: Label = $titulo
@onready var ingreso: LineEdit = $datos/ingreso
@onready var resultado: Label = $datos/resultado

func _ready():
	titulo.text = nombre
	ingreso.placeholder_text = unidad
	ingreso.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
	ingreso.text_changed.connect(func(_t): cambio.emit())
	ManagerConfig.estilizar_label(titulo, "titulo")
	ManagerConfig.estilizar_label(ingreso, "ingreso")
	ManagerConfig.estilizar_label(resultado, "resultado")

# número del campo, o null si está vacío o inválido
func valor():
	var t := ingreso.text.strip_edges().replace(",", ".")
	if t == "" or not t.is_valid_float():
		return null
	return t.to_float()

func set_configuracion(nuevo_titulo: String, nueva_hint: String):
	titulo.text = nuevo_titulo
	ingreso.placeholder_text = nueva_hint

func mostrar_resultado(v, calculado: bool):
	resultado.text = ("= %.2f" % v) if calculado else ""
