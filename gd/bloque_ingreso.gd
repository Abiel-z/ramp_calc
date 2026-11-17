class_name BloqueIngreso
extends VBoxContainer

signal cambio

@export var nombre: String = ""
@export var unidad: String = ""
@export var clave: String = ""

var _hint := ""

@export var icono_candado: Texture2D
@onready var icono_error: TextureRect = $datos/ingreso/icono_error

@onready var titulo: Label = $titulo
@onready var ingreso: LineEdit = $datos/ingreso
@onready var resultado: Label = $datos/resultado


var _error: IndicadorError

func _ready():
	titulo.text = nombre
	_hint = unidad
	_refrescar_hint()
	ingreso.placeholder_text = unidad
	ingreso.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
	ManagerConfig.estilizar_label(titulo, "titulo")
	ManagerConfig.estilizar_label(ingreso, "ingreso")
	ManagerConfig.estilizar_label(resultado, "resultado")
	
	_error = IndicadorError.new(ingreso, icono_error)
	ingreso.text_changed.connect(_on_text_changed)
	
	ingreso.focus_entered.connect(_error.limpiar)
	ingreso.focus_exited.connect(_validar_al_salir)
	ingreso.text_submitted.connect(func(_t): ingreso.release_focus())
	Ajustes.unidad_cambiada.connect(_on_unidad_cambiada)


func _on_text_changed(_t: String) -> void:
	_error.limpiar()
	cambio.emit()

func _validar_al_salir() -> void:
	if tiene_texto() and valor() == null:
		_error.mostrar(ManagerConfig.get_color("global", "error_color"), 0.0)

func valor():
	if not RampaCalculo.LIMITES.has(clave):
		push_warning("BloqueIngreso sin clave válida: '%s'" % clave)
		return null
	var lim: Dictionary = RampaCalculo.LIMITES[clave]
	var longitud := Unidades.es_longitud(clave)
	# validas con los límites expresados en la unidad que ve la persona
	var mn: float = Unidades.de_cm(lim["min"]) if longitud else lim["min"]
	var mx: float = Unidades.de_cm(lim["max"]) if longitud else lim["max"]
	var r := RampaCalculo.validar_numero(ingreso.text, mn, mx)
	if not r.has("valor"):
		return null
	return Unidades.a_cm(r["valor"]) if longitud else r["valor"]   # al modelo siempre en cm


func tiene_texto() -> bool:
	return not ingreso.text.strip_edges().is_empty()

func set_configuracion(nuevo_titulo: String, nueva_hint: String):
	titulo.text = nuevo_titulo
	_hint = nueva_hint            # puede llevar {u}: "Altura en {u}"
	_refrescar_hint()

func _refrescar_hint() -> void:
	ingreso.placeholder_text = _hint.replace("{u}", Unidades.actual())

func _on_unidad_cambiada() -> void:
	ingreso.text = ""             # los números escritos ya no valen en la unidad nueva
	_error.limpiar()
	_refrescar_hint()
	cambio.emit()                 # el panel desbloquea y recalcula


func mostrar_resultado(v, calculado: bool):
	if not calculado:
		resultado.text = ""
	elif v == null:
		resultado.text = "Fuera de rango"
	elif Unidades.es_longitud(clave):
		resultado.text = "= %s %s" % [String.num(Unidades.de_cm(v), Unidades.decimales()), Unidades.actual()]
	else:
		resultado.text = "= %s" % String.num(v, 2)
#func mostrar_resultado(v, calculado: bool):
	#resultado.text = ("= %.2f" % v) if calculado else ""

func set_bloqueado(v: bool) -> void:
	ingreso.editable = not v
	ingreso.right_icon = icono_candado if v else null
	if v:
		ingreso.release_focus()
