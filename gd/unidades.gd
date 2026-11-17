# unidades.gd
class_name Unidades
extends RefCounted

const FACTOR := {"cm": 1.0, "m": 100.0, "in": 2.54}   # cuántos cm vale una unidad
const DECIMALES := {"cm": 1, "m": 3, "in": 2}
const CLAVES_LONGITUD := ["altura", "largo", "ancho", "cota"]

static func actual() -> String:
	var u: String = Ajustes.obtener("general", "unidad")
	return u if FACTOR.has(u) else "cm"

static func cambiar(u: String) -> void:
	if FACTOR.has(u) and u != actual():
		Ajustes.guardar("general", "unidad", u)
		Ajustes.unidad_cambiada.emit()

static func es_longitud(clave: String) -> bool:
	return clave in CLAVES_LONGITUD

static func a_cm(v: float) -> float:
	return v * FACTOR[actual()]

static func de_cm(cm: float) -> float:
	return cm / FACTOR[actual()]

static func decimales() -> int:
	return DECIMALES[actual()]

# para textos sueltos, como las cotas del 3D
static func formatear(cm: float) -> String:
	var s := str(snappedf(de_cm(cm), pow(10.0, -decimales())))
	return s.trim_suffix(".0").replace(".", ",") + " " + actual()
