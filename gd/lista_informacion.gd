# lista_informacion.gd
extends VBoxContainer

signal seleccionado(id: String)
signal valor_editado(id: String, campo: String, valor: float)
signal eliminar_solicitado(id: String)

const BLOQUE_ESCENA: PackedScene = preload("res://tscn/bloque_informacion.tscn")

var _bloques := {}   # id -> BloqueInformacion

func mostrar_plan(elementos: Array, _sumar := false) -> void:
	var varios := _hay_varias_rampas(elementos)
	if _mismos_ids(elementos):
		for e in elementos:
			_bloques[e.id].actualizar(e, varios)
		return
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_bloques.clear()
	for e in elementos:
		var b: BloqueInformacion = BLOQUE_ESCENA.instantiate()
		add_child(b)
		b.cargar(e, varios)
		b.tocado.connect(seleccionado.emit)
		b.valor_editado.connect(valor_editado.emit)
		b.eliminar_solicitado.connect(eliminar_solicitado.emit)
		_bloques[e.id] = b

# "más de un cuerpo" = el plan tiene más de una rampa
func _hay_varias_rampas(elementos: Array) -> bool:
	return elementos.filter(func(x): return x.tipo == "rampa").size() > 1

func _mismos_ids(elementos: Array) -> bool:
	if elementos.size() != _bloques.size():
		return false
	for e in elementos:
		if not _bloques.has(e.id):
			return false
	return true

func resaltar(id: String) -> void:
	for k in _bloques:
		_bloques[k].resaltar(k == id)

func mostrar_bloque(id: String) -> void:
	await get_tree().process_frame
	var scroll := get_parent() as ScrollContainer
	if scroll and _bloques.has(id) and is_instance_valid(_bloques[id]):
		scroll.ensure_control_visible(_bloques[id])
