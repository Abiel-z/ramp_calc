# selector_temas.gd
class_name SelectorTemas
extends HFlowContainer

signal premium_solicitado(id: String)

@export var icono_candado: Texture2D
@export var tamano := Vector2(52, 52)

var _botones := {}    # id -> Button
var _candados := {}   # id -> TextureRect

func _ready() -> void:
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 10)
	for id in ManagerTemas.TEMAS:
		var b := Button.new()
		b.custom_minimum_size = tamano
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_on_boton.bind(id))
		add_child(b)

		var c := TextureRect.new()
		c.texture = icono_candado
		c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		c.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
		b.add_child(c)

		_botones[id] = b
		_candados[id] = c

	if OS.is_debug_build():
		_crear_interruptor_debug()

	ManagerTemas.tema_cambiado.connect(_refrescar)
	_refrescar()

func _on_boton(id: String) -> void:
	if not ManagerTemas.set_tema(id):
		premium_solicitado.emit(id)
	_refrescar()

func _refrescar() -> void:
	var color_sel := ManagerConfig.get_color("seleccion", "color")
	for id in _botones:
		var b: Button = _botones[id]
		var muestra: Color = ManagerTemas.TEMAS[id].get("muestra", Color.GRAY)
		var activo : bool = id == ManagerTemas.tema_actual
		var bloqueado := not ManagerTemas.puede_usar(id)

		var sb := StyleBoxFlat.new()
		sb.bg_color = muestra
		sb.border_color = color_sel if activo else Color(0, 0, 0, 0.35)
		sb.set_border_width_all(4 if activo else 1)
		sb.set_corner_radius_all(8)
		for estado in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(estado, sb)

		var c: TextureRect = _candados[id]
		c.visible = bloqueado and icono_candado != null
		# candado negro sobre colores claros, blanco sobre oscuros
		c.modulate = Color.BLACK if muestra.get_luminance() > 0.6 else Color.WHITE

# solo en depuración: simula el pago para probar los temas
func _crear_interruptor_debug() -> void:
	var c := CheckButton.new()
	c.text = "es_pago (debug)"
	c.button_pressed = ManagerTemas.es_pago
	c.toggled.connect(func(v: bool) -> void:
		ManagerTemas.es_pago = v
		if not ManagerTemas.puede_usar(ManagerTemas.tema_actual):
			ManagerTemas.set_tema("claro")
		_refrescar()
	)
	add_child(c)
