# rampa_plan.gd
class_name RampaPlan

const ANCHO_PRUEBA := 150.0   # rampa y descanso, por ahora fijos

static func simple(r: Dictionary) -> Array:
	return [
		{"tipo": "rampa", "id": "rampa_1", "indice": 0,
		 "cota_inicio": 0.0, "cota_fin": r.altura, "largo": r.largo, "ancho": ANCHO_PRUEBA},
	]

static func sumar(actual: Array, nuevo: Array) -> Array:
	if actual.is_empty():
		return nuevo
	if nuevo.is_empty():
		return actual

	var cuenta := {"rampa": 0, "descanso": 0}
	for e in actual:
		cuenta[e.tipo] += 1

	# descanso intermedio a la cota donde termina lo actual
	var cota_union: float = actual[-1].cota_fin
	var descanso := {
		"tipo": "descanso", "id": "", "indice": 0,
		"cota_inicio": cota_union, "cota_fin": cota_union,
		"largo": 150.0, "ancho": ANCHO_PRUEBA,
	}

	var dc: float = cota_union - nuevo[0].cota_inicio
	var resultado: Array = actual.duplicate()

	var piezas: Array = [descanso]
	for n in nuevo:
		var e: Dictionary = n.duplicate()
		e.cota_inicio += dc
		e.cota_fin += dc
		piezas.append(e)

	for e in piezas:
		cuenta[e.tipo] += 1
		e.id = "%s_%d" % [e.tipo, cuenta[e.tipo]]
		e.indice = resultado.size()
		resultado.append(e)
	return resultado
	
static func editar(plan: Array, id: String, campo: String, valor: float) -> Array:
	if valor <= 0.0:
		return plan
	var res: Array = []
	for p in plan:
		res.append(p.duplicate())
	var idx := -1
	for i in res.size():
		if res[i].id == id:
			idx = i
	if idx < 0:
		return plan

	var el: Dictionary = res[idx]
	var dz: float = el.cota_fin - el.cota_inicio
	match campo:
		"largo":
			el.largo = valor                      # mismo desnivel: cambia la pendiente
		"ancho":
			el.ancho = valor
		"pendiente":
			if el.tipo != "rampa" or dz <= 0.0:
				return plan
			el.largo = dz / (valor / 100.0)       # mismo desnivel: cambia el largo
		"desnivel":
			if el.tipo != "rampa":
				return plan
			var pend: float = dz / el.largo if el.largo > 0.0 else 0.0
			if pend > 0.0:
				el.largo = valor / pend           # misma pendiente: cambia el largo
			el.cota_fin = el.cota_inicio + valor
		_:
			return plan

	# las piezas siguientes se acomodan a la nueva cota de salida
	for i in range(idx + 1, res.size()):
		var d: float = res[i - 1].cota_fin - res[i].cota_inicio
		res[i].cota_inicio += d
		res[i].cota_fin += d
	return res
