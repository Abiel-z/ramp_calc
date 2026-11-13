extends PanelContainer

const SIMULAR_TECLADO := true

@onready var panel: PanelContainer = self

var _top0 := 0.0
var _bottom0 := 0.0
var _base_bottom := 0.0   # dónde termina el panel en reposo (coordenadas de pantalla)
var _desp := 0.0          # cuánto está subido ahora

func _ready():
	# lo que dejaste en el editor, sin modificar anchors
	_top0 = panel.offset_top
	_bottom0 = panel.offset_bottom
	await get_tree().process_frame            # esperar a que el layout se resuelva
	_base_bottom = panel.get_global_rect().end.y

func _process(delta):
	if _base_bottom == 0.0:
		return

	var vp_h := get_viewport_rect().size.y
	var escala := vp_h / float(DisplayServer.window_get_size().y)
	var kb := _altura_teclado_px() * escala

	# cuánto hay que subir para que el borde de abajo quede justo sobre el teclado
	var destino := maxf(0.0, _base_bottom - (vp_h - kb))

	if absf(_desp - destino) < 0.5:
		_desp = destino
	else:
		_desp = lerpf(_desp, destino, 1.0 - exp(-delta * 15.0))

	panel.offset_top = _top0 - _desp
	panel.offset_bottom = _bottom0 - _desp

func _altura_teclado_px() -> float:
	if OS.has_feature("android"):
		return DisplayServer.virtual_keyboard_get_height()
	if SIMULAR_TECLADO:
		var f := get_viewport().gui_get_focus_owner()
		if f is LineEdit:
			return DisplayServer.window_get_size().y * 0.4
	return 0.0
