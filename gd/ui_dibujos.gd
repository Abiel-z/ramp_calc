extends Control

@onready var container: SubViewportContainer = $container_visor3d

func _ready() -> void:
	var mat := container.material as ShaderMaterial
	if mat == null:
		push_error("container_visor_3d no tiene un ShaderMaterial asignado")
		return
	ManagerConfig.vincular_shader(mat, "contorno")
	mat.set_shader_parameter("color_linea", Color.RED)   # prueba temporal
	print("shader: ", mat.shader.resource_path)
	for u in mat.shader.get_shader_uniform_list():
		print("uniform: ", u.name)
	_buscar_materiales(get_tree().root)
	var mat_inicial := container.material
	print("al inicio: ", mat_inicial.get_instance_id())
	await get_tree().create_timer(1.0).timeout
	print("1 segundo después: ", container.material.get_instance_id())

func _buscar_materiales(n: Node) -> void:
	if n is CanvasItem and n.material is ShaderMaterial:
		print(n.get_path(), " -> ", n.material.shader.resource_path)
	for h in n.get_children():
		_buscar_materiales(h)
