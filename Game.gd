extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("lmb"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# delta is a fraction of a second

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		get_tree().reload_current_scene()
	
	fire_missile_occasionally(delta)


var next_fire: float
var sec_elapsed = 0.0
func fire_missile_occasionally(delta):
	sec_elapsed += delta
	if sec_elapsed < next_fire:
		return
	
	fire_missile()
	next_fire = rand_range(0, 1)
	sec_elapsed = 0

onready var missile_scene = load("res://Missile.tscn")

func fire_missile():
	print("launching missile")
	var launch_origin = random_point_on_sphere(100.0)
	
	var missile = missile_scene.instance()
	missile.translate(launch_origin)
	
	#TODO: Could be fun to pick a voxel as a target, so they come in at weird angles
	missile.target = $Planet
	var speed = rand_range(20, 50)
	missile.velocity = ($Planet.global_transform.origin - launch_origin).normalized() * speed
	add_child(missile)
	
	missile.connect("missile_impact", $Planet, "_on_Emitter_missile_impact")
	

func random_point_on_sphere(radius: float):
	# I don't think this is a uniform distribution on the sphere,
	# but hey... it's good enough, right?! RIGHT?!?!
	
	# Generate a random point in a box with a half-width of radius.
	# The box surrounds the sphere.
	var point = Vector3(
		rand_range(-radius, radius),
		rand_range(-radius, radius),
		rand_range(-radius, radius)
	)
	
	# Move the point along a normal such that it's magnitude is the radius.
	return point.normalized() * radius
