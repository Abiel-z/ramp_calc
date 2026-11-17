extends VBoxContainer

const ITEM_ESCENA := preload("res://tscn/item_config.tscn")

@onready var button_reset := $boton_reset

func _ready() -> void:

	for item in ManagerConfig.DEFAULTS:
		var nodo: ItemConfig = ITEM_ESCENA.instantiate()
		add_child(nodo)
		nodo.setup(item)

	button_reset.text = "Restablecer valores"
	button_reset.pressed.connect(ManagerConfig.reset)

	visibility_changed.connect(_on_visibilidad)

func _on_visibilidad() -> void:
	if not is_visible_in_tree():
		get_viewport().gui_release_focus()
		DisplayServer.virtual_keyboard_hide()
