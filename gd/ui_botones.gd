class_name UIBotones
extends Control

enum Estado { CALCULO, INFORMACION, CONFIGURACION }

signal estado_pedido(estado: Estado)

@onready var botones := {
	Estado.CALCULO: $Barra/BotonCalculo,
	Estado.INFORMACION: $Barra/BotonInformacion,
	Estado.CONFIGURACION: $Barra/BotonConfiguracion,
}

func _ready() -> void:
	var grupo := ButtonGroup.new()
	for e in botones:
		var b: Button = botones[e]
		b.toggle_mode = true
		b.button_group = grupo
		b.pressed.connect(func(): estado_pedido.emit(e))
	botones[Estado.CALCULO].set_pressed_no_signal(true)

func marcar(estado: Estado) -> void:
	botones[estado].set_pressed_no_signal(true)
