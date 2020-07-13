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


var blast_radius: float

func _ready():
	blast_radius = 1.0

signal surface_missile_impact(impact_site, blast_radius)

func emit_surface_missile_impact_signal(impact_site, blast_radius):
	print("emitting signal")
	emit_signal("surface_missile_impact", impact_site, blast_radius)
	

var impacted = false

var t = 0
func _process(delta):
	t += delta
	if t > 1.0:
		t = 1.0
	
	if !impacted:
		global_transform.origin = sine_lerp(t)

	if t >= 1.0 and !impacted:
		impacted = true
		emit_surface_missile_impact_signal(end, blast_radius)
	
	#TODO: Shoot a ray out from the core again, to make sure the surface tile is still intact for impact.

# 0 to 1
func sine_lerp(t: float):
	var x = lerp(0, PI, t)
	var unit_height = sin(x)
	
	
	var height = height_from_mid * unit_height
	#print("height ", height, " start ", start, " end ", end)
	
	
	var spot = start.linear_interpolate(end, t)
	var mid = start.linear_interpolate(end, 0.5)
	var dir = (mid - core).normalized()
	
	return spot + (dir * height)
	
	#var spot = start.linear_interpolate(end, t)
	#var ray = spot - core
	#ray = ray.normalized() * (ray.length() + height)
	#return core + ray
