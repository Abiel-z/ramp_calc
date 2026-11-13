# lista_informacion.gd
extends VBoxContainer

signal seleccionado(id: String)
signal valor_editado(id: String, campo: String, valor: float)

var _bloques := {}   # id -> BloqueInformacion

func mostrar_plan(elementos: Array, _sumar := false) -> void:
	if _mismos_ids(elementos):
		for e in elementos:
			_bloques[e.id].actualizar(_filas(e))
		return
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_bloques.clear()
	for e in elementos:
		var b := BloqueInformacion.new()
		add_child(b)
		b.cargar(e.id, e.id.replace("_", " ").capitalize(), _filas(e))
		b.tocado.connect(seleccionado.emit)
		b.valor_editado.connect(valor_editado.emit)
		_bloques[e.id] = b

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

func _filas(e) -> Array:
	var dz: float = absf(e.cota_fin - e.cota_inicio)
	if e.tipo == "rampa":
		var pend: float = dz / e.largo * 100.0 if e.largo > 0.0 else 0.0
		return [
			{"campo": "largo", "nombre": "Largo (cm)", "valor": e.largo, "editable": true},
			{"campo": "ancho", "nombre": "Ancho (cm)", "valor": e.ancho, "editable": true},
			{"campo": "pendiente", "nombre": "Pendiente (%)", "valor": pend, "editable": true},
			{"campo": "desnivel", "nombre": "Desnivel (cm)", "valor": dz, "editable": true},
			{"campo": "alt_min", "nombre": "Altura mín. (cm)", "valor": minf(e.cota_inicio, e.cota_fin), "editable": false},
			{"campo": "alt_max", "nombre": "Altura máx. (cm)", "valor": maxf(e.cota_inicio, e.cota_fin), "editable": false},
		]
	return [
		{"campo": "largo", "nombre": "Largo (cm)", "valor": e.largo, "editable": true},
		{"campo": "ancho", "nombre": "Ancho (cm)", "valor": e.ancho, "editable": true},
		{"campo": "altura", "nombre": "Altura (cm)", "valor": e.cota_inicio, "editable": false},
	]
