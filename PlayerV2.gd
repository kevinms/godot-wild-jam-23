extends KinematicBody

# if it doesn't work, create a planet that is a sibling and switch to transform

#export var mouse_sensitivity = 0.002 # radians / pixel

export(NodePath) var planet_path
onready var planet = get_node(planet_path)

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

func global_input_direction():
	var dir = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir += -global_transform.basis.z.normalized()
	if Input.is_action_pressed("back"):
		dir += global_transform.basis.z.normalized()
	if Input.is_action_pressed("left"):
		dir += -global_transform.basis.x.normalized()
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x.normalized()
	
	return dir.normalized()
	#return dir

var velocity: Vector3
var gravity_magnitude = 40
var speed = 7
var air_speed = 30
var jump = 20
var jump_magnitude = 40
var jump_time_delta = 0

var jumping = false

func _physics_process(delta):
	var world_up = (global_transform.origin - planet.global_transform.origin).normalized()

	var xform = align_with_y(global_transform, world_up)
	global_transform = global_transform.interpolate_with(xform, 1.0)

	# Round 1:
	#   Keep track of global velocity
	#   We want acceleration
	
	# Save what component of velocity is gravity
	var gravity_component = velocity.project(-world_up)
	
	# Updated velocity
	var dir = global_input_direction()
	
	if !jumping:
		if dir == Vector3.ZERO:
			$Alien/AnimationPlayer.play("idle-loop")
		else:
			$Alien/AnimationPlayer.play("run-loop", -1, 2.0)
	
	if Input.is_action_just_pressed("shield"):
		$Shield.activate()
	
	if jumping:
		jump_time_delta += delta
		velocity += dir * air_speed * delta
		if velocity.length() > speed:
			velocity = velocity.normalized() * speed
	else:
		velocity = dir * speed
	
	if !jumping && Input.is_action_just_pressed("jump"):
		$Alien/AnimationPlayer.play("jump-spin")
		$JumpSound.play()
		# Override gravity if we jumped
		velocity -= gravity_component
	
		# Only cancel out gravity_component if it points down -- this let's jumps compound velocity.
		#if gravity_component.dot(-world_up) > 0:
		#       velocity -= gravity_component

		velocity += global_transform.basis.y.normalized() * jump
		jumping = true
	else:
		# Add back gravity, but in the current direction of gravity
		#velocity += -world_up * gravity_component.length() # gravity_component points either up or down (it's not just gravity), so if it points up, we get it's magnitude and apply it down... oops
		if !jumping:
			velocity += gravity_component
		if jumping and jump_time_delta < 0.3 and Input.is_action_pressed("jump"):
			velocity += world_up * (jump_magnitude * delta)
			
		velocity += -world_up * (gravity_magnitude * delta)
	
	# Option #1
	#var collision = move_and_collide(velocity * delta)
	#if collision:
	#	jumping = false
	#	velocity = velocity.slide(collision.normal)
	
	# Option #2
	velocity = move_and_slide(velocity, world_up, true, 4, PI/2)
	if get_slide_count() > 0:
		jumping = false
		jump_time_delta = 0
	
	# Option #3
	#var snap = (-global_transform.basis.y + dir) * 2.0
	#velocity = move_and_slide_with_snap(velocity, snap, world_up, true)
	#if get_slide_count() > 0:
	#	jumping = false

# Get the surface normal of w/e is beneath us. This is used as the up vector for move_and_slide() to prevent the extra sliding!
func get_floor_normal():
	var from = global_transform.origin
	var to = global_transform.origin + (-global_transform.basis.y.normalized() * 5)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		#print("beneath me: ", result.normal)
		return result.normal
	return global_transform.basis.y.normalized()

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
