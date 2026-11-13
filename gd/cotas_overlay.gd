class_name CotasOverlay
extends Control

#const COLOR := Color("#ff4d4d")
#const GROSOR := 2.0
#const TAM_FUENTE := 22

var camara: Camera3D
var _cotas: Array = []
var _sel := PackedVector3Array()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # los toques pasan al visor 3D

func set_cotas(cotas: Array):
	_cotas = cotas
	queue_redraw()

func set_seleccion(esquinas: PackedVector3Array) -> void:
	_sel = esquinas
	queue_redraw()

func _process(_delta):
	if not _cotas.is_empty() or not _sel.is_empty():
		queue_redraw()

func _draw():
	if camara == null:
		return
	var fuente := ThemeDB.fallback_font
	var color := ManagerConfig.get_color("cotas")
	var tam_fuente := int(ManagerConfig.get_size("cotas"))
	var grosor: float = ManagerConfig.get_valor("cotas", "grosor_linea")
	
	var borde: float = ManagerConfig.get_valor("cotas", "contorno_texto")
	var color_borde := ManagerConfig.get_color("cotas", "color_contorno")
	
	
	for c in _cotas:
		for s in c.segmentos:
			if camara.is_position_behind(s[0]) or camara.is_position_behind(s[1]):
				continue
			var p0 := camara.unproject_position(s[0])
			var p1 := camara.unproject_position(s[1])
			if p0.distance_to(p1) < 1.0:
				continue
			draw_line(p0, p1, color, grosor, true)

		if camara.is_position_behind(c.pos_texto):
			continue
		var p := camara.unproject_position(c.pos_texto)
		var tam := fuente.get_string_size(c.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente)
		var pos: Vector2
		if c.texto_centrado:
			pos = p + Vector2(-tam.x / 2.0, -10.0)    # centrado, un poco sobre la línea
		else:
			pos = p + Vector2(10.0, tam.y / 4.0)      # a la derecha de la línea
		pos = pos.round()   # evita que el texto quede borroso por caer entre píxeles
		if borde > 0.0:
			draw_string_outline(fuente, pos, c.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente, int(borde), color_borde)
		draw_string(fuente, pos, c.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente, color)
		
	if _sel.size() >= 3:
		
		var pts := PackedVector2Array()
		for e in _sel:
			if camara.is_position_behind(e):
				return
			pts.append(camara.unproject_position(e))
		draw_polyline(Geometry2D.convex_hull(pts),
			ManagerConfig.get_color("seleccion", "color"),
			ManagerConfig.get_valor("seleccion", "grosor"), true)
