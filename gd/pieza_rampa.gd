# pieza_rampa.gd
class_name PiezaRampa
extends Node3D

const CM := 0.01
const SHADER_PIEZA := preload("res://shaders/pieza_plana.gdshader")
const COLOR_RAMPA := Color("#4f8cff")
const COLOR_DESCANSO := Color("#ffb84f")

var id: String = ""
var indice: int = 0
var cota_base: float = 0.0     # cota mínima del conjunto (suelo), cm
var cota_inicio: float = 0.0
var cota_fin: float = 0.0
var largo: float = 0.0
var ancho: float = 0.0

func construir():
	pass

func _p(x: float, y: float, z: float) -> Vector3:
	return Vector3(x, y, z) * CM

# las 8 esquinas del prisma, en coordenadas locales: [a0 a1 a2 a3 b0 b1 b2 b3]
func _calcular_esquinas() -> PackedVector3Array:
	var base := cota_base
	if is_equal_approx(cota_inicio, cota_fin) and cota_inicio - base < 1.0:
		base = cota_inicio - 1.0   # pieza plana a nivel del suelo: al menos 1 cm de espesor
	var w := ancho / 2.0
	return PackedVector3Array([
		_p(0.0,   base,        -w),   # a0
		_p(largo, base,        -w),   # a1
		_p(largo, cota_fin,    -w),   # a2
		_p(0.0,   cota_inicio, -w),   # a3
		_p(0.0,   base,         w),   # b0
		_p(largo, base,         w),   # b1
		_p(largo, cota_fin,     w),   # b2
		_p(0.0,   cota_inicio,  w),   # b3
	])

# esquinas en coordenadas globales (para proyectarlas a pantalla)
func esquinas() -> PackedVector3Array:
	var r := PackedVector3Array()
	for v in _calcular_esquinas():
		r.append(to_global(v))
	return r

# prisma macizo: base en cota_base, cara superior de cota_inicio a cota_fin
func _solido(tinte: Color) -> MeshInstance3D:
	var e := _calcular_esquinas()
	var a0 := e[0]
	var a1 := e[1]
	var a2 := e[2]
	var a3 := e[3]
	var b0 := e[4]
	var b1 := e[5]
	var b2 := e[6]
	var b3 := e[7]

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_cara(st, b0, b3, b2, b1)   # frente (+Z)
	_cara(st, a0, a1, a2, a3)   # atrás (-Z)
	_cara(st, a3, a2, b2, b3)   # arriba
	_cara(st, a0, b0, b1, a1)   # abajo
	_cara(st, a0, a3, b3, b0)   # inicio (-X)
	_cara(st, a1, b1, b2, a2)   # fin (+X)

	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = SHADER_PIEZA
	mat.set_shader_parameter("tinte", tinte)
	mi.material_override = mat
	add_child(mi)
	return mi

# cara de 4 vértices, en sentido horario visto desde afuera (como pide Godot)
func _cara(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3):
	var n := -(b - a).cross(c - a)
	if n.length() < 0.0000001:
		n = -(c - a).cross(d - a)
	if n.length() < 0.0000001:
		return   # cara sin área (por ejemplo, la punta de la rampa)
	n = n.normalized()
	for v in [a, b, c, a, c, d]:
		st.set_normal(n)
		st.add_vertex(v)
