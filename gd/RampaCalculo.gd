class_name RampaCalculo
extends RefCounted

const LIMITES := {
	"altura": {"min": 1.0, "max": 500.0},
	"largo": {"min": 1.0, "max": 10000.0},
	"pendiente": {"min": 0.5, "max": 100.0},
	"ancho": {"min": 10.0, "max": 500.0},
	"cota": {"min": 0.0, "max": 1000.0},
}

static func en_rango(clave: String, v: float) -> bool:
	if not LIMITES.has(clave):
		return true
	return v >= LIMITES[clave]["min"] and v <= LIMITES[clave]["max"]
	
## Recibe 2 de 3 variables (la que no se sabe va en null) y calcula la tercera.
static func calcular(altura = null, largo = null, pendiente = null) -> Dictionary:
	var res := {
		"ok": false,
		"altura": altura,
		"largo": largo,
		"pendiente": pendiente,
		"calculado": "",   # cuál de las tres se calculó
		"errores": [],
	}

	# cuántas variables vinieron
	var datos := 0
	for v in [altura, largo, pendiente]:
		if v != null:
			datos += 1

	if datos != 2:
		res.errores.append("Ingresa exactamente 2 variables (altura, largo o pendiente).")
		return res

	# todo lo ingresado debe ser positivo
	for v in [altura, largo, pendiente]:
		if v != null and v <= 0:
			res.errores.append("Los valores deben ser mayores que 0.")
			return res

	if pendiente == null:
		res.pendiente = altura / largo * 100.0
		res.calculado = "pendiente"
	elif largo == null:
		res.largo = altura / (pendiente / 100.0)
		res.calculado = "largo"
	else:
		res.altura = largo * (pendiente / 100.0)
		res.calculado = "altura"
	
	if not en_rango(res.calculado, res[res.calculado]):
		res[res.calculado] = null
		res.errores.append("Resultado fuera de rango")
		return res
	
	res.ok = true
	return res

static func validar_numero(texto: String, minimo: float, maximo: float) -> Dictionary:
	var t := texto.strip_edges().replace(",", ".")  # en Chile se escribe 8,5
	if t.is_empty():
		return {"estado": "vacio"}
	if not t.is_valid_float():
		return {"estado": "error", "mensaje": "Solo números"}
	var v := t.to_float()
	if v < minimo or v > maximo:
		return {"estado": "error", "mensaje": "Entre %s y %s" % [minimo, maximo]}
	return {"estado": "ok", "valor": v}
