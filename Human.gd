extends KinematicBody

var speed = 1
var jump = 3
var gravity = 2

export(NodePath) var planet_path
onready var planet = get_node(planet_path)

export(NodePath) var alien_path
onready var alien = get_node(alien_path)

var global_velocity = Vector3()
var jumping = false

var fear = 1.0
var fear_radius = 4
var mark_radius = 2.5

func set_fear(v: float):
	var mark_radius = 1.5
	if fear < mark_radius and v > mark_radius:
		$ExclamationPlayer.play("Squishy bounce")
		$ExclamationMark.show()
	if fear > mark_radius and v < mark_radius:
		$ExclamationPlayer.stop()
		$ExclamationMark.hide()
	fear = v

func _ready():
	print(alien)

func _physics_process(delta):
	# Jump
	if is_on_floor() and randf() < 1.0:
		# Always jump up
		global_velocity = global_transform.basis.y * rand_range(0, jump)
		jumping = true
		
		# Distance to alien
		var ray_to_alien = alien.global_transform.origin - global_transform.origin
		if ray_to_alien.length() < fear_radius:
			set_fear(fear_radius / ray_to_alien.length())
			#var forward = -global_transform.basis.z.normalized()
			#var new_dir = forward.rotated(global_transform.basis.y, rand_range(0, 2*PI))
			var new_dir = -ray_to_alien.normalized()
			global_velocity += new_dir * speed * fear
		else:
			set_fear(1.0)
			# Determine the direction
			var forward = -global_transform.basis.z.normalized()
			var new_dir = forward.rotated(global_transform.basis.y, rand_range(0, 2*PI))
			global_velocity += new_dir * speed

	var accel = Vector3()

	# Gravity
	accel += -global_transform.basis.y * 500 * delta
	
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
