extends VBoxContainer

func _ready() -> void:
	for g in ManagerConfig.DEFAULTS:
		var cab := Label.new()
		cab.name = "titulo_" + g
		cab.text = g.capitalize()
		add_child(cab)
		ManagerConfig.estilizar_label(cab, "titulo")
		for k in ManagerConfig.DEFAULTS[g]:
			var b := BloqueConfig.new()
			add_child(b)
			b.setup(g, k)
		add_child(HSeparator.new())

	var reset := Button.new()
	reset.text = "Restablecer valores"
	reset.pressed.connect(ManagerConfig.reset)
	add_child(reset)

	visibility_changed.connect(_on_visibilidad)

func _on_visibilidad() -> void:
	if not is_visible_in_tree():
		get_viewport().gui_release_focus()
		DisplayServer.virtual_keyboard_hide()
