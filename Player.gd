extends KinematicBody

# if it doesn't work, create a planet that is a sibling and switch to transform

var velocity: Vector3
var gravity = Vector3(0, -40, 0)
var speed = 20
var jump = 20
#export var mouse_sensitivity = 0.002 # radians / pixel

export(NodePath) var planet_path
onready var planet = get_node(planet_path)

func local_input_direction():
	var dir = Vector3()
	
	if Input.is_action_pressed("forward"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("back"):
		dir += Vector3.BACK
	if Input.is_action_pressed("left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("right"):
		dir += Vector3.RIGHT
	
	return dir.normalized()

func draw_velocity():
	var offset = Vector3.UP * 4
	var begin = to_global(offset)
	var end = to_global(velocity.normalized() + offset)
	
	$"/root/DebugDraw".reset($Debug)
	#$"/root/DebugDraw".global_line($Debug, global_transform.origin + shift, to_global(velocity) + shift)
	$"/root/DebugDraw".global_line($Debug, begin, end)

func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var angle = -event.relative.x * GlobalStats.mouse_sensitivity
			#rotate_y(-event.relative.x * GlobalStats.mouse_sensitivity)
			
			rotate_object_local(Vector3.UP, angle)

func _physics_process(delta):
	var world_up = (global_transform.origin - planet.global_transform.origin).normalized()
	var world_down = (planet.global_transform.origin - global_transform.origin).normalized()
	
	#velocity +=  world_down * 20 * delta
	
	var dir = local_input_direction()
	
	# Convert direction to global space (probaby a better way...)
	#dir = (to_global(dir) - global_transform.origin).normalized()
	#velocity += dir # The problem is that we continuously add but never reset

	# "velocity" is always in local space.
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	#velocity.y += -20 * delta
	#velocity.y = 0
	velocity.y = -20
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump
	
	# Convert "velocity" to global space because that's what move_and_slide() expects.
	var global_velocity = to_global(velocity) - global_transform.origin
	
	# Using floor_normal causes jitter when player is at rest
	#var floor_normal = get_floor_normal()
	
	global_velocity = move_and_slide(global_velocity, world_up, true)
	#global_velocity = move_and_slide(global_velocity, -global_transform.basis.y, true)
	
	# Update local "velocity" to account for changes move_and_slide() made.
	velocity = to_local(global_transform.origin + global_velocity) - transform.origin
	
	#print(velocity)
	#draw_velocity()
	
	#velocity = move_and_slide_with_snap(velocity, Vector3.DOWN*2, Vector3.UP, true)
	#velocity = move_and_slide(velocity, Vector3.UP, true)
	#global_transform = align_with_y(global_transform, world_up)
	var xform = align_with_y(global_transform, world_up)
	global_transform = global_transform.interpolate_with(xform, 0.2)

# Get the surface normal of w/e is beneath us. This is used as the up vector for move_and_slide() to prevent the extra sliding!
func get_floor_normal():
	var from = global_transform.origin
	var to = global_transform.origin + (-global_transform.basis.y.normalized() * 5)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		print("beneath me: ", result.normal)
		return result.normal
	return global_transform.basis.y.normalized()

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
