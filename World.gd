extends Spatial

var voxelScene = load("res://Voxel.tscn")
export var radius = 7

var noise = OpenSimplexNoise.new()

func init_noise():
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	init_noise()
	generate_world()
	
	# Connect to missile_impact signal
	#get_node("Emitter").connect("missile_impact", self, "_on_Emitter_missile_impact")

var matrix = []

func modulate_single_color():
	var color = Color(
		rand_range(0, 0.1),
		rand_range(0.5,1),
		rand_range(0,0.1)
	)
	return color

func simplex_all_color(x, y, z):
	var color = Color(
		noise.get_noise_3d(x, y, z) + 1 / 2,
		noise.get_noise_3d(x+1, y, z) + 1 / 2,
		noise.get_noise_3d(x+2, y, z) + 1 / 2
	)
	return color

func simplex_green_color(x, y, z):
	var color = Color(
		0,
		noise.get_noise_3d(x+1, y, z) + 0.5 / 1,
		0
	)
	return color

func simplex_two_color(x, y, z):
	var green = Vector3(0,1,0)
	var blue = Vector3(0,0,1)
	
	var t = 3
	green.linear_interpolate(blue, t)
	
	var color: Color
	var n = noise.get_noise_3d(x, y, z) + 0.5 / 1
	if noise.get_noise_3d(x, y, z) < 0:
		color.g = n
	else:
		color.b = n
	
	return color

func gen_voxel(x, y, z):
	var voxel = voxelScene.instance()
	
	var pos = Vector3(x, y, z)
	voxel.translate(pos)
	add_child(voxel)
	
	#var color = modulate_single_color()
	#var color = simplex_all_color(x, y, z)
	#var color = simplex_green_color(x, y, z)
	var color = simplex_two_color(x, y, z)
	
	print(color)
	
	var material = voxel.get_node("MeshInstance").get_surface_material(0).duplicate()
	material.albedo_color = color
	voxel.get_node("MeshInstance").set_surface_material(0, material)
	
	return voxel

func generate_world():
	for x in range(-radius, radius):
		matrix.append([])
		for y in range(-radius, radius):
			matrix[x+7].append([])
			for z in range(-radius, radius):
				var dist = sqrt( pow(x, 2) + pow(y, 2) + pow(z, 2) )
				
				if dist < radius:
					var voxel = gen_voxel(x, y, z)
					voxel.connect("missile_impact", self, "_on_Emitter_missile_impact")
					matrix[x+7][y+7].append(voxel)

func _on_Emitter_missile_impact(impact_site, blast_radius):
	print("impact_site ", impact_site, " blast_raduis ", blast_radius)
	
	var space_state = get_world().direct_space_state
	
	# Create the intersection shape
	var sphere = SphereShape.new()
	sphere.radius = 3.0
	
	# Configure the query parameters
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(sphere)
	#query.set_transform(get_transform())
	
	query.transform = Transform(Basis.IDENTITY, impact_site)
	#query.set_exclude(excludes)
	
	var max_results = 32
	var results = space_state.intersect_shape(query, max_results)
	
	for result in results:
		var collider = result["collider"]
		if collider.name == "Player":
			print("Ouchie")
		else:
			collider.queue_free()
#
#	print("hi")
