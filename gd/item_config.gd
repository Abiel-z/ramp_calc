class_name ItemConfig
extends FoldableContainer

const FILA_DATO := preload("res://tscn/fila_dato.tscn")
const FILA_COLOR := preload("res://tscn/fila_color.tscn")

@onready var _caja: VBoxContainer = $caja

var item := ""
var _filas := {}   # clave -> FilaDato o FilaColor

func setup(nombre_item: String) -> void:
	item = nombre_item
	name = "item_" + nombre_item
	title = nombre_item.capitalize()
	folded = true
	for k in ManagerConfig.DEFAULTS[item]:
		var base = ManagerConfig.DEFAULTS[item][k]["valor"]   # <- el cambio
		var fila = (FILA_COLOR if base is Color else FILA_DATO).instantiate()
		fila.campo = k
		fila.nombre = k.capitalize()
		if fila is FilaDato:
			fila.decimales = 2
		_caja.add_child(fila)
		fila.valor_editado.connect(_on_editado)
		fila.actualizar(ManagerConfig.get_valor(item, k))
		_filas[k] = fila
	ManagerConfig.config_cambiada.connect(_on_config_cambiada)

func _on_editado(campo: String, valor) -> void:
	ManagerConfig.set_valor(item, campo, valor)
	# por si set_valor corrigió el número (min/max) o no cambió nada
	_filas[campo].actualizar(ManagerConfig.get_valor(item, campo))

# refresca las filas cuando cambia algo desde otro lado (ej. el botón Restablecer)
func _on_config_cambiada(grupo: String, clave: String) -> void:
	if grupo == item and _filas.has(clave):
		_filas[clave].actualizar(ManagerConfig.get_valor(grupo, clave))
