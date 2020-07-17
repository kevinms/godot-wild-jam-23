extends Spatial

onready var intro_scene = load("res://Human.tscn")

var selected_mesh: MeshInstance

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#var angle = -event.relative.y * mouse_sensitivity
		var result = click_raycast(event)
		if result:
			# We clicked someting! But... what?!
			
			if result.collider == $Intro:
				set_selected($"Intro/menu-intro")
			if result.collider == $Play:
				set_selected($"Play/menu-play")
		else:
			set_selected(null)

func set_selected(mesh):
	if selected_mesh != null and selected_mesh != mesh:
		selected_mesh.scale = Vector3.ONE
	
	selected_mesh = mesh
	
	if selected_mesh != null:
		selected_mesh.scale = Vector3.ONE * 1.3

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = click_raycast(event)
		
		if result:
			# We clicked someting! But... what?!
			
			if result.collider == $Intro:
				Global.goto_scene("res://Intro.tscn")
			elif result.collider == $Play:
				Global.goto_scene("res://Game.tscn")

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		get_tree().reload_current_scene()

const ray_length = 1000

func click_raycast(event):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * ray_length
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		#print("Ray hit: ", result.position)
		return result
