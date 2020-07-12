extends MultiMeshInstance

var radius = 40

func _ready():
	# Create the multimesh.
	multimesh = MultiMesh.new()
	
	# Set the format first.
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#multimesh.color_format = MultiMesh.COLOR_NONE
	#multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	
	# Then resize (otherwise, changing the format is not allowed).
	multimesh.instance_count = pow(radius*2, 3)
	# Maybe not all of them should be visible at first.
	multimesh.visible_instance_count = multimesh.instance_count
	
	
	var mesh = CubeMesh.new()
	mesh.size = Vector3(1,1,1)
	multimesh.mesh = mesh
	
	# Set the transform of the instances.
	for i in multimesh.visible_instance_count:
		var pos = indexToCoord(i, radius*2, radius*2)
		
		pos -= Vector3(radius, radius, radius)
		
		var dist = pos.length()
		if dist <= radius:
			multimesh.set_instance_transform(i, Transform(Basis(), pos))
		else:
			multimesh.set_instance_transform(i, Transform(Basis(), Vector3()))

func indexToCoord(i, max_x, max_y):
	var x = i % (max_x+1)
	i /= (max_x+1)
	var y = i % (max_y+1)
	i /= (max_y+1)
	var z = i
	return Vector3(x, y, z)

func coordToIndex(x, y, z, max_x, max_y):
	var a = 1
	var b = max_x + 1
	var c = (max_x + 1) * (max_y + 1)
	var d = 0
	return a*x + b*y + c*z + d


func _process(delta):
	rotate_y(delta)
	rotate_x(delta)

# Destroying cubes could just change their transform so they are outside of view (super tiny?, behind a sky map)

# array[x][y]



func generate_world():
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			for z in range(-radius, radius):
				var dist = sqrt( pow(x, 2) + pow(y, 2) + pow(z, 2) )
				
				if dist < radius:
					#var voxel = gen_voxel(x, y, z, dist)
					pass
