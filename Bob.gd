extends KinematicBody

var gravity = -30
var speed = 20
var jump = 30

var velocity = Vector3()
var acceleration = Vector3()

var gravity_origin = Vector3()

func _ready():
	pass

func input_direction():
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

func _physics_process(delta):
	$"/root/DebugDraw".reset($Debug)
	
	#attempt_1(delta)
	#attempt_2(delta)
	
	attempt_3(delta)

func attempt_3(delta):
	pass

func attempt_2(delta):
	# target rotation
	# current rotation
	# quaternion.slerp()
	
	# In Global space
	var player_up = global_transform.basis.y.normalized()
	var world_up = (global_transform.origin - gravity_origin).normalized()
	
	var player_forward = global_transform.basis.z.normalized()
	
	var target = global_transform.origin + world_up.cross(player_forward)
	
	$"/root/DebugDraw".global_sphere($Debug, target)
	
	global_transform = global_transform.looking_at(target, player_up)
	
	var p0 = global_transform.origin
	var p1 = global_transform.origin + -global_transform.basis.y.normalized()
	
	$"/root/DebugDraw".global_line($Debug, p0, p1)
	
	#var current_rot = Quat(transform.basis)
	#var new_rot = current_rot.slerp(Matrix3(x, y, z), dt*3.0)

func attempt_1(delta):
	# Get the input direction in local space
	var dir = input_direction()
	
	# Convert direction to global space (probaby a better way...)
	dir = to_global(dir) - global_transform.origin
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = dir.y * jump
	
	# Apply gravity based on global gravity_origin
	var gravity_up =  global_transform.origin - gravity_origin
	velocity += gravity_up.normalized() * gravity * delta
	
	# Apply jump force after gravity so it can override it
	if Input.is_action_just_pressed("jump"):
		pass
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
