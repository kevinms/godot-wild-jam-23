extends KinematicBody

var speed = 1
var jump = 2
var gravity = 2

export(NodePath) var planet_path
onready var planet = get_node(planet_path)

var global_velocity = Vector3()
var jumping = false

func _physics_process(delta):
	# Jump
	if is_on_floor() and randf() < 0.01:
		# Always jump up
		global_velocity = global_transform.basis.y * jump
		jumping = true
		
		# Determine the direction
		var forward = -global_transform.basis.z.normalized()
		var new_dir = forward.rotated(global_transform.basis.y, rand_range(0, 2*PI))
		global_velocity += new_dir * speed

	var accel = Vector3()

	# Gravity
	accel += -global_transform.basis.y * gravity * delta
	
	# Apply acceleration
	global_velocity += accel * delta
	
	var world_up = (global_transform.origin - planet.global_transform.origin).normalized()
	
	if jumping:
		global_velocity = move_and_slide(global_velocity, world_up, true)
	else:
		global_velocity = move_and_slide_with_snap(global_velocity, -world_up*2, world_up, true)
	
	if get_slide_count() > 0:
		jumping = false
		global_velocity = Vector3()
	
	var xform = align_with_y(global_transform, world_up)
	global_transform = global_transform.interpolate_with(xform, 0.2)

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	#TODO: Set scale back to before orthonormalized()?
	return xform
