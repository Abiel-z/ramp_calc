class_name RampaCalculo

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

	res.ok = true
	return res
