extends KinematicBody

var start: Vector3
var end: Vector3
var core: Vector3
var height_from_mid: float

func init(start: Vector3, end: Vector3, core: Vector3, height_from_mid: float):
	self.start = start
	self.end = end
	self.core = core
	self.height_from_mid = height_from_mid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var ticks = 0

var t = 0
func _process(delta):
	t += delta
	if t > 1.0:
		t = 1.0
	
	ticks += 1
	if ticks % 10 && t < 1.0:
		global_transform.origin = sine_lerp(t)
	
	#TODO: Shoot a ray out from the core again, to make sure the surface tile is still intact for impact.

# 0 to 1
func sine_lerp(t: float):
	var x = lerp(0, PI, t)
	var unit_height = sin(x)
	
	
	var height = height_from_mid * unit_height
	print("height ", height, " start ", start, " end ", end)
	
	
	var spot = start.linear_interpolate(end, t)
	var mid = start.linear_interpolate(end, 0.5)
	var dir = (mid - core).normalized()
	
	return spot + (dir * height)
	
	#var spot = start.linear_interpolate(end, t)
	#var ray = spot - core
	#ray = ray.normalized() * (ray.length() + height)
	#return core + ray
