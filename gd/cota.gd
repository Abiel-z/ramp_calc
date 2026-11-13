# cota.gd
class_name Cota
extends RefCounted

const CM := 0.01
const DESFASE_VERTICAL_CM := 60.0   # antes lo que tuvieras; súbelo hasta que no se confunda con la rampa
const ALTO_COTA_TOTAL_CM := 60.0   

var segmentos: Array = []        # pares [Vector3, Vector3], en metros
var texto := ""
var pos_texto := Vector3.ZERO    # punto 3D al que se ancla el texto
var texto_centrado := true       # false: el texto parte a la derecha del punto


static func horizontal(a_cm: Vector3, b_cm: Vector3, y_linea_cm: float, texto: String) -> Cota:
	var c := Cota.new()
	var a := a_cm * CM
	var b := b_cm * CM
	var y := y_linea_cm * CM
	var a2 := Vector3(a.x, y, a.z)
	var b2 := Vector3(b.x, y, b.z)
	var sobra := Vector3.UP * 0.05
	c.segmentos = [[a, a2 + sobra], [b, b2 + sobra], [a2, b2]]
	c.texto = texto
	c.pos_texto = (a2 + b2) / 2.0
	return c

static func vertical(x_cm: float, z_cm: float, y0_cm: float, y1_cm: float, desfase_x_cm: float, texto: String) -> Cota:
	var c := Cota.new()
	var p0 := Vector3(x_cm, y0_cm, z_cm) * CM
	var p1 := Vector3(x_cm, y1_cm, z_cm) * CM
	var d := Vector3(desfase_x_cm * CM, 0.0, 0.0)
	var sobra := d.normalized() * 0.05
	c.segmentos = [[p0, p0 + d + sobra], [p1, p1 + d + sobra], [p0 + d, p1 + d]]
	c.texto = texto
	c.pos_texto = (p0 + p1) / 2.0 + d
	c.texto_centrado = false
	return c
