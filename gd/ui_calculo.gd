extends VBoxContainer

signal proyectar_solicitado(elementos: Array, sumar: bool)

@onready var b_altura: BloqueIngreso = $ingreso_altura
@onready var b_largo: BloqueIngreso = $ingreso_largo
@onready var b_pendiente: BloqueIngreso = $ingreso_pendiente

var _bloques: Array[BloqueIngreso]

@onready var boton_sumar: Button = $botones/sum

func _ready():
	_bloques = [b_altura, b_largo, b_pendiente]

	# TEXTOS HARCOREADOS DEBEN ESTAR EN UNA CENTRAL DE TRADUCCIÓN
	b_altura.set_configuracion("Altura", "Altura en cm")
	b_largo.set_configuracion("Largo", "Largo en cm")
	b_pendiente.set_configuracion("Pendiente", "Pendiente en %")
	
	for b in _bloques:
		b.cambio.connect(_on_cambio)

func _on_cambio():
	_actualizar_bloqueos()
	_recalcular()

func _actualizar_bloqueos() -> void:
	var llenos := _bloques.filter(func(b): return b.tiene_texto()).size()
	for b in _bloques:
		# solo se bloquea el que está vacío, y solo cuando ya hay 2 llenos
		b.set_bloqueado(llenos >= 2 and not b.tiene_texto())

func _recalcular():
	var r = RampaCalculo.calcular(b_altura.valor(), b_largo.valor(), b_pendiente.valor())
	b_altura.mostrar_resultado(r.altura, r.calculado == "altura")
	b_largo.mostrar_resultado(r.largo, r.calculado == "largo")
	b_pendiente.mostrar_resultado(r.pendiente, r.calculado == "pendiente")

func _on_boton_proyectar_pressed() -> void:
	# cerrar el teclado para que el panel baje y se vea el 3D
	get_viewport().gui_release_focus()
	DisplayServer.virtual_keyboard_hide()

	var r = RampaCalculo.calcular(b_altura.valor(), b_largo.valor(), b_pendiente.valor())
	if not r.ok:
		push_warning("\n".join(r.errores))   # más adelante lo mostramos en un Label
		return

	proyectar_solicitado.emit(RampaPlan.simple(r), boton_sumar.button_pressed)
