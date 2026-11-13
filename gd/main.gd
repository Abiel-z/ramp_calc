extends Control

@onready var ui_calculos = $VBoxContainer/UI_paneles/panel_calculo/ui_calculo
@onready var visualizer: Visualizer = $VBoxContainer/UI_dibujos/container_visor3d/Visor3D/Visualizer
@onready var con_visualizer := $VBoxContainer/UI_dibujos/container_visor3d
@onready var overlay : CotasOverlay = $VBoxContainer/UI_dibujos/cotas_overlay
@onready var info_lista = $VBoxContainer/UI_paneles/panel_informacion/ScrollContainer/lista

@onready var ui_botones = $VBoxContainer/UI_botones
@onready var ui_paneles = $VBoxContainer/UI_paneles

var plan_actual: Array = []

func _ready():
	ui_botones.estado_pedido.connect(ui_paneles.mostrar)
	ui_paneles.mostrar(UIBotones.Estado.CALCULO)

	overlay.camara = visualizer.camara
	visualizer.cotas_generadas.connect(overlay.set_cotas)

	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/contorno.gdshader")
	con_visualizer.material = mat
	ManagerConfig.vincular_shader(mat, "contorno")
	
	visualizer.pieza_seleccionada.connect(func(_id, esq): overlay.set_seleccion(esq))
	#ui_calculos.proyectar_solicitado.connect(visualizer.dibujar)
	
	ui_calculos.proyectar_solicitado.connect(info_lista.mostrar_plan)
	info_lista.seleccionado.connect(visualizer.seleccionar)
	visualizer.pieza_seleccionada.connect(func(id: String, esq: PackedVector3Array):
		overlay.set_seleccion(esq)
		info_lista.resaltar(id)
		if id != "":
			ui_paneles.mostrar(UIBotones.Estado.INFORMACION)
			ui_botones.marcar(UIBotones.Estado.INFORMACION)
			info_lista.mostrar_bloque(id)
)
	ui_calculos.proyectar_solicitado.connect(_on_proyectar)
	info_lista.valor_editado.connect(_on_valor_editado)

func _on_valor_editado(id: String, campo: String, valor: float) -> void:
	plan_actual = RampaPlan.editar(plan_actual, id, campo, valor)
	info_lista.mostrar_plan(plan_actual)
	visualizer.dibujar(plan_actual, true)

func _on_proyectar(plan_nuevo: Array, sumar: bool) -> void:
	plan_actual = RampaPlan.sumar(plan_actual, plan_nuevo) if sumar else plan_nuevo
	visualizer.dibujar(plan_actual)
	info_lista.mostrar_plan(plan_actual)
