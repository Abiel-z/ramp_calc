class_name Visualizer
extends Node3D

const SEPARACION_TOTAL_CM := 60.0    # cuánto más arriba que las cotas individuales va la total
const DESFASE_VERTICAL_CM := 30.0    # separa la cota vertical del eje de la rampa
const SUBIR_TEXTO_VERTICAL_CM := 0.0

const Z_COTA_PENDIENTE := 0.0
const SEP_CM := 30.0     # cuánto se separa la cota de la superficie
const MARCA_CM := 8.0    # largo de las marcas de los extremos

signal cotas_generadas(cotas: Array)
signal pieza_seleccionada(id: String, esquinas: PackedVector3Array)

@onready var camara: Camera3D = $Camera3D

var edicion : bool = false
var _sel_id := ""
var _tap_inicio := Vector2.ZERO
var _tap_valido := false

var _ultimos_elementos: Array = []


# --- cámara orbital ---
var _objetivo := Vector3.ZERO   # punto que mira la cámara (centro de la rampa)
var _dist := 5.0
var _dist_min := 1.0
var _dist_max := 20.0
var _yaw := 0.59                # giro horizontal (rad)
var _pitch := 0.43              # inclinación (rad)

var _toques := {}               # dedos apoyados: índice -> posición
var _dist_pellizco := 0.0

func _ready():
	# fondo y luz ambiente
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#1b2030")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.5
	camara.environment = env

	ManagerConfig.config_cambiada.connect(func(g: String, k: String):
		if g == "contorno" and k == "fondo_3d":
			env.background_color = ManagerConfig.get_color(g, k)
	)


	# luz direccional para que se noten las caras
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45.0, -40.0, 0.0)
	add_child(luz)
	Ajustes.unidad_cambiada.connect(_on_unidad_cambiada)

func _on_unidad_cambiada():
	if _ultimos_elementos.is_empty():
		return
	dibujar(_ultimos_elementos, true)

func _encuadrar(largo_total: float, altura: float):
	_objetivo = Vector3(largo_total / 2.0, altura / 2.0, 0.0) * PiezaRampa.CM
	_dist = maxf(largo_total, 200.0) * PiezaRampa.CM * 1.0   # baja el 1.0 si la quieres más cerca
	_dist_min = _dist * 0.25
	_dist_max = _dist * 2.5
	_actualizar_camara()

func _actualizar_camara():
	var dir := Vector3(sin(_yaw) * cos(_pitch), sin(_pitch), cos(_yaw) * cos(_pitch))
	camara.position = _objetivo + dir * _dist
	camara.look_at(_objetivo, Vector3.UP)

func _unhandled_input(event):
	_detectar_tap_mouse(event)
	if event is InputEventScreenTouch:
		if event.pressed:
			_toques[event.index] = event.position
			_tap_valido = _toques.size() == 1
			_tap_inicio = event.position
		else:
			if _tap_valido and _toques.size() == 1:
				_tap(event.position)
			_tap_valido = false
			_toques.erase(event.index)
		_dist_pellizco = 0.0

	elif event is InputEventScreenDrag:
		if _tap_valido and event.position.distance_to(_tap_inicio) > 12.0:
			_tap_valido = false
		var centro_antes := _centro_toques()   # punto medio ANTES de este movimiento
		_toques[event.index] = event.position

		if _toques.size() == 1:
			_orbitar(event.relative)
		elif _toques.size() == 2:
			# 1) mover el punto de rotación con el desplazamiento del punto medio
			_panear(_centro_toques() - centro_antes)
			# 2) zoom con el cambio de distancia entre dedos
			var p: Array = _toques.values()
			var d: float = p[0].distance_to(p[1])
			if _dist_pellizco > 0.0:
				_dist = clampf(_dist * _dist_pellizco / d, _dist_min, _dist_max)
			_dist_pellizco = d
			_actualizar_camara()
	
	elif event is InputEventMouseMotion:
		if _tap_valido and event.position.distance_to(_tap_inicio) > 12.0:
			_tap_valido = false
		if _toques.is_empty():
			if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
				_orbitar(event.relative)
			elif event.button_mask & (MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE):
				_panear(event.relative)
	
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_dist = clampf(_dist * 0.9, _dist_min, _dist_max)
			_actualizar_camara()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_dist = clampf(_dist * 1.1, _dist_min, _dist_max)
			_actualizar_camara()
	

func _orbitar(delta: Vector2):
	_yaw -= delta.x * 0.01
	_pitch = clampf(_pitch + delta.y * 0.01, 0.05, 1.45)
	_actualizar_camara()

# punto medio de todos los dedos apoyados
func _centro_toques() -> Vector2:
	if _toques.is_empty():
		return Vector2.ZERO
	var suma := Vector2.ZERO
	for pos in _toques.values():
		suma += pos
	return suma / _toques.size()

# mover el punto que mira la cámara, en el plano de la pantalla
func _panear(delta_px: Vector2):
	var alto := get_viewport().get_visible_rect().size.y
	var m_por_px := 2.0 * _dist * tan(deg_to_rad(camara.fov) / 2.0) / alto
	var base := camara.global_transform.basis
	_objetivo -= base.x * delta_px.x * m_por_px   # dedos a la derecha: la escena va a la derecha
	_objetivo += base.y * delta_px.y * m_por_px   # dedos abajo: la escena baja
	_actualizar_camara()

func dibujar(elementos: Array, edicion := false):
	_ultimos_elementos = elementos
	var id_sel := _sel_id
	_limpiar()
	if not edicion:
		seleccionar("")

	# cota mínima del conjunto = el "suelo"
	var cota_min := INF
	for e in elementos:
		cota_min = minf(cota_min, minf(e.cota_inicio, e.cota_fin))

	var x := 0.0
	var cota_max := 0.0
	var ancho_max := 0.0
	var tramos := []

	for e in elementos:
		var p: PiezaRampa
		if e.tipo == "rampa":
			p = Rampa.new()
		else:
			p = Descanso.new()
		p.id = e.id
		p.indice = e.indice
		p.cota_base = cota_min
		p.cota_inicio = e.cota_inicio
		p.cota_fin = e.cota_fin
		p.largo = e.largo
		p.ancho = e.ancho
		p.position = Vector3(x, 0.0, 0.0) * PiezaRampa.CM
		add_child(p)
		p.construir()

		tramos.append({"x0": x, "x1": x + e.largo, "c0": e.cota_inicio, "c1": e.cota_fin})
		x += e.largo
		cota_max = maxf(cota_max, e.cota_fin)
		ancho_max = maxf(ancho_max, e.ancho)

	cotas_generadas.emit(_generar_cotas(tramos, x, cota_min, cota_max, ancho_max))
	if edicion:
		seleccionar(id_sel)   # la selección pasa a las piezas nuevas
	else:
		_encuadrar(x, cota_max)

func _generar_cotas(tramos: Array, largo_total: float, cota_min: float, cota_max: float, ancho_max: float) -> Array:
	var cotas := []
	if tramos.is_empty():
		return cotas

	var y_linea := cota_max + 80.0

	# cotas individuales
	for t in tramos:
		cotas.append(Cota.horizontal(
			Vector3(t.x0, t.c0, 0.0), Vector3(t.x1, t.c1, 0.0),
			y_linea, Unidades.formatear(t.x1 - t.x0)))

	# cota total, solo si hay más de una pieza
	if tramos.size() > 1:
		cotas.append(Cota.horizontal(
			Vector3(0.0, tramos[0].c0, 0.0), Vector3(largo_total, tramos[-1].c1, 0.0),
			y_linea + SEPARACION_TOTAL_CM, Unidades.formatear(largo_total)))

	# cota de altura total
	cotas.append(Cota.vertical(largo_total, 0.0, cota_min, cota_max, DESFASE_VERTICAL_CM,
		Unidades.formatear(cota_max - cota_min)))

	for t in tramos:
		if not is_equal_approx(t.c0, t.c1):
			cotas.append(_cota_inclinada(t, cota_min, Z_COTA_PENDIENTE))

	return cotas

func _limpiar():
	for h in get_children():
		if h is PiezaRampa:
			h.queue_free()

func _fmt(v: float) -> String:
	var r := snappedf(v, 0.1)
	if is_equal_approx(r, roundf(r)):
		return str(int(roundf(r)))          # 150.0 -> "150"
	return str(r).replace(".", ",")         # 150.5 -> "150,5"

func _on_boton_return_pressed() -> void:
	_yaw = 0.59
	_pitch = 0.50
	_objetivo = Vector3.ZERO

	_dist = 5.0
	_dist_min = 1.0
	_dist_max = 20.0

	_actualizar_camara()

func _silueta(esq: PackedVector3Array) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for e in esq:
		if camara.is_position_behind(e):
			return PackedVector2Array()
		pts.append(camara.unproject_position(e))
	return Geometry2D.convex_hull(pts)

func _tap(pos: Vector2) -> void:
	print("tap en ", pos)
	var elegido: PiezaRampa = null
	var mejor := INF
	for h in get_children():
		if not (h is PiezaRampa) or h.is_queued_for_deletion():
			continue
		var esq: PackedVector3Array = h.esquinas()
		var poly := _silueta(esq)
		print(h.id, " esquinas: ", esq.size(), " silueta: ", poly.size())
		if poly.size() < 3 or not Geometry2D.is_point_in_polygon(pos, poly):
			continue
		var c := Vector3.ZERO
		for e in esq:
			c += e
		c /= esq.size()
		var d := camara.global_position.distance_squared_to(c)
		if d < mejor:
			mejor = d
			elegido = h
	seleccionar(elegido.id if elegido else "")

func seleccionar(id: String) -> void:
	_sel_id = id
	var esq := PackedVector3Array()
	for h in get_children():
		if h is PiezaRampa and h.id == id and not h.is_queued_for_deletion():
			esq = h.esquinas()
	pieza_seleccionada.emit(id, esq)

func _detectar_tap_mouse(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.pressed:
			_tap_inicio = event.position
			_tap_valido = true
		else:
			if _tap_valido:
				_tap(event.position)
			_tap_valido = false
	elif event is InputEventMouseMotion and _tap_valido:
		if event.position.distance_to(_tap_inicio) > 12.0:
			_tap_valido = false

func _cota_inclinada(t: Dictionary, cota_min: float, z: float) -> Dictionary:
	var cm := PiezaRampa.CM
	var a := Vector3(t.x0, t.c0 - cota_min + SEP_CM, z) * cm
	var b := Vector3(t.x1, t.c1 - cota_min + SEP_CM, z) * cm
	var marca := Vector3(0.0, MARCA_CM, 0.0) * cm

	var largo: float = t.x1 - t.x0
	var pend: float = absf(t.c1 - t.c0) / largo * 100.0 if largo > 0.0 else 0.0
	var texto := str(snappedf(pend, 0.1)).trim_suffix(".0").replace(".", ",") + " %"

	return {
		"segmentos": [
			[a, b],
			[a - marca, a + marca],
			[b - marca, b + marca],
		],
		"pos_texto": (a + b) / 2.0,
		"texto": texto,
		"texto_centrado": true,
	}
