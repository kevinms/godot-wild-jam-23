extends KinematicBody

var max_speed = 50
var speed = 1000
var jump = 20
var gravity = 100

#onready var planet = $"../Planet"
export(NodePath) var planet_path
onready var planet = get_node(planet_path)

var global_velocity = Vector3()

func _physics_process(delta):
	
	rotate_object_local(Vector3.UP, 0.01)

	var accel = Vector3()
	
	# Move forward
	#if randf() < 0.4:
	#	accel += global_transform.basis.z * speed * delta
	
	#var forward_vector = global_velocity.project(global_transform.basis.z)
	#if forward_vector.length() > max_speed:
	#	global_velocity -= forward_vector.normalized() * (forward_vector.length() - max_speed)
	
	# Gravity
	accel += -global_transform.basis.y * gravity * delta
	
	# Apply acceleration
	global_velocity += accel * delta
	
	# Jump
	#if randf() < 0.1 and is_on_floor():
		# We want the jump to initially cancel out all force due to gravity
		
		# Project our velocity onto the local Y axis
		# This gets the component of velocity in the direction of gravity
		#var scalar_projection = global_velocity.dot(-global_transform.basis.y) / global_velocity.length()
		#var vector_projection = -global_transform.basis.y * scalar_projection
		
		# Subtract that component from the velocity to cancel out all gravity
		#global_velocity -= vector_projection
		#global_velocity += global_transform.basis.y * jump
	
	var world_up = (global_transform.origin - planet.global_transform.origin).normalized()
	
	global_velocity = move_and_slide_with_snap(global_velocity, -world_up*2, world_up, true)
	
	if get_slide_count() > 0:
		print("Collided with planet... hopefully")
	
	var xform = align_with_y(global_transform, world_up)
	global_transform = global_transform.interpolate_with(xform, 0.2)

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	#TODO: reset scale
	return xform
