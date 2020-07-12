extends KinematicBody

var noise = OpenSimplexNoise.new()

var velocity: Vector3
var gravity = Vector3(0, -40, 0)
var speed = 20
var jump = 20

#onready var planet = $"../Planet"
export(NodePath) var planet_path
onready var planet = get_node(planet_path)

func init_noise():
	noise.seed = randi()
	noise.octaves = 7
	noise.period = 20.0
	noise.persistence = 0.8

func local_input_direction():
	var dir = Vector3()
	
	var pos = global_transform.origin
	
	if noise.get_noise_3dv(pos) > 0:
		dir += Vector3.FORWARD
	elif noise.get_noise_3dv(pos) > 0:
		dir += Vector3.BACK
	elif noise.get_noise_3dv(pos) > 0:
		dir += Vector3.LEFT
	elif noise.get_noise_3dv(pos) > 0:
		dir += Vector3.RIGHT
	
	return dir.normalized()

func _physics_process(delta):
	
	#rotate_object_local(Vector3.UP, 0.01)
	
	var world_up = (global_transform.origin - planet.global_transform.origin).normalized()
	var world_down = (planet.global_transform.origin - global_transform.origin).normalized()
	
	var dir = local_input_direction()

	# "velocity" is always in local space.
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	velocity.y = -20
	
	if Input.is_action_pressed("jump"):
		velocity.y = jump
	
	# Convert "velocity" to global space because that's what move_and_slide() expects.
	var global_velocity = to_global(velocity) - global_transform.origin
	
	global_velocity = move_and_slide(global_velocity, world_up, true)
	
	# Update local "velocity" to account for changes move_and_slide() made.
	velocity = to_local(global_transform.origin + global_velocity) - transform.origin
	
	var xform = align_with_y(global_transform, world_up)
	global_transform = global_transform.interpolate_with(xform, 0.2)

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
