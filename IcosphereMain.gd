extends Spatial

const ray_length = 1000

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = $Camera
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			print("Ray hit: ", result.position)
			
			var closest = $Icosphere.octree.knn(result.position, 32)
			print(closest)
