extends Spatial

onready var material = $MeshInstance.get_surface_material(0)

func _input(event):
	if event.is_action_pressed("lmb"):
		#material.set_shader_param("start_time_0", time)
		material.set_shader_param("start_time_0", float(OS.get_ticks_msec()) / 1000.0)
		material.set_shader_param("start_time_1", float(OS.get_ticks_msec()) / 1000.0)

var time = 0
func _process(delta):
	material.set_shader_param("global_time", time)
	time += delta
