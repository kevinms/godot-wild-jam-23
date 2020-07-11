extends Node

func reset(node: Node):
	for child in node.get_children():
		child.queue_free()

func sphere(node: Spatial, p0: Vector3, color = Color(1,0,0), scale = 1.0):
	var mesh = MeshInstance.new()
	mesh.mesh = SphereMesh.new()
	mesh.translation = p0
	mesh.scale *= scale
	
	var material = SpatialMaterial.new()
	material.albedo_color = color
	mesh.set_surface_material(0, material)
	
	node.add_child(mesh)

func global_sphere(node: Spatial, p0: Vector3, color = Color(1,0,0), scale = 1.0):
	sphere(node, node.to_local(p0), color, scale)

func line(node: Spatial, p0: Vector3, p1: Vector3, color = Color(1,0,0), n_segments = 8):
	for i in range(0, n_segments+1):
		var pos = p0.linear_interpolate(p1, float(i) / n_segments)
		
		var mesh = MeshInstance.new()
		mesh.mesh = SphereMesh.new()
		mesh.translation = pos
		mesh.scale *= 0.05
		
		var material = SpatialMaterial.new()
		if i == n_segments:
			color = Color()
		material.albedo_color = color
		mesh.set_surface_material(0, material)
		
		node.add_child(mesh)

func global_line(node: Spatial, p0: Vector3, p1: Vector3, color = Color(1,0,0), n_segments = 8):
	line(node, node.to_local(p0), node.to_local(p1), color, n_segments)
