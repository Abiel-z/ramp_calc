extends PanelContainer

const NOMBRES := {"cm": "Centímetros (cm)", "m": "Metros (m)", "in": "Pulgadas (in)"}
@onready var opt_unidad : OptionButton = $caja/config_unidad/selector_unidad

func _ready():
	for u in Unidades.FACTOR:
		opt_unidad.add_item(NOMBRES[u])
		opt_unidad.set_item_metadata(opt_unidad.item_count - 1, u)
		if u == Unidades.actual():
			opt_unidad.select(opt_unidad.item_count - 1)
	opt_unidad.item_selected.connect(func(i): Unidades.cambiar(opt_unidad.get_item_metadata(i)))
