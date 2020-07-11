extends Spatial

var voxelScene = load("res://Voxel.tscn")
export var radius = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_world()
	
	# Connect to missile_impact signal
	#get_node("Emitter").connect("missile_impact", self, "_on_Emitter_missile_impact")

var matrix = []

func generate_world():
	for x in range(-radius, radius):
		matrix.append([])
		for y in range(-radius, radius):
			matrix[x+7].append([])
			for z in range(-radius, radius):
				var dist = sqrt( pow(x, 2) + pow(y, 2) + pow(z, 2) )
				
				if dist < radius:
					var voxel = voxelScene.instance()
					
					var pos = Vector3(x, y, z)
					voxel.translate(pos)
					add_child(voxel)
					voxel.connect("missile_impact", self, "_on_Emitter_missile_impact")
					matrix[x+7][y+7].append(voxel)

func _on_Emitter_missile_impact(impact_site, blast_radius):
	print("impact_site ", impact_site, " blast_raduis ", blast_radius)
	
	var space_state = get_world().direct_space_state
	
	# Create the intersection shape
	var sphere = SphereShape.new()
	sphere.radius = 2.0
	
	# Configure the query parameters
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(sphere)
	#query.set_transform(get_transform())
	
	query.transform = Transform(Basis.IDENTITY, impact_site)
	
	var max_results = 32
	var results = space_state.intersect_shape(query, max_results)
	
	for result in results:
		var collider = result["collider"]
		collider.queue_free()
#
#	print("hi")
