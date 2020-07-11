extends Spatial

var voxelScene = load("res://Voxel.tscn")
export var radius = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			for z in range(-radius, radius):
				
				var dist = sqrt( pow(x, 2) + pow(y, 2) + pow(z, 2) )
				
				if dist < radius:
					var voxel = voxelScene.instance()
					
					var pos = Vector3(x, y, z)
					voxel.translate(pos)
					add_child(voxel)
