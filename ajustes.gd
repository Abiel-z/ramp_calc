# ajustes.gd (autoload "Ajustes")
extends Node

signal unidad_cambiada

const ARCHIVO := "user://ajustes.cfg"
const DEFECTOS := {
	"apariencia": {"tema": "claro"},
	"general": {"unidad": "cm", "mantener_pantalla": false},
}

var _cfg := ConfigFile.new()

func _ready() -> void:
	_cfg.load(ARCHIVO)   # si no existe, queda vacío y se usan los defectos
	DisplayServer.screen_set_keep_on(obtener("general", "mantener_pantalla"))

func obtener(seccion: String, clave: String):
	return _cfg.get_value(seccion, clave, DEFECTOS[seccion][clave])

func guardar(seccion: String, clave: String, valor) -> void:
	_cfg.set_value(seccion, clave, valor)
	_cfg.save(ARCHIVO)    # al instante: en Android no hay que esperar al cierre
