extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var missile_scene = load("res://SurfaceMissile.tscn")
	var missile = missile_scene.instance()
	
	var start = Vector3.LEFT
	var end = Vector3.RIGHT
	var core = Vector3.DOWN
	var height_from_mid = 2.0
	missile.init(start, end, core, height_from_mid)
	
	add_child(missile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
