extends Control

@onready var paneles := {
	UIBotones.Estado.CALCULO: $panel_calculo,
	UIBotones.Estado.INFORMACION: $panel_informacion,
	UIBotones.Estado.CONFIGURACION: $panel_configuracion,
}

var estado_actual: int = -1

func mostrar(nuevo: int) -> void:
	if estado_actual == nuevo:
		return
	if paneles.has(estado_actual) and paneles[estado_actual].has_method("al_salir"):
		paneles[estado_actual].al_salir()
	estado_actual = nuevo
	for e in paneles:
		paneles[e].visible = (e == nuevo)
	if paneles[nuevo].has_method("al_entrar"):
		paneles[nuevo].al_entrar()
