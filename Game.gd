extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spawn_humans()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("lmb"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()
	
	click_raycast(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# delta is a fraction of a second

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		get_tree().reload_current_scene()
	
	#fire_missile_occasionally(delta)



const ray_length = 1000
export var num_humans = 100
onready var human_scene = load("res://Human.tscn")

var prev_click_position = Vector3.ZERO

func click_raycast(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = get_viewport().get_camera()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			print("Ray hit: ", result.position)
			
			#var closest = $Planet.octree.knn(result.position, 32)
			#print(closest)
			
			if prev_click_position != Vector3.ZERO:
				# Fire missle between two clicks
				launch_surface_missile(prev_click_position, result.position)
				prev_click_position = Vector3.ZERO
			else:
				prev_click_position = result.position



onready var surface_missile_scene = load("res://SurfaceMissile.tscn")
var surface_missile_height = 5

func launch_surface_missile(start: Vector3, end: Vector3):
	var mid = start.linear_interpolate(end, 0.5)
	var core_to_mid = mid - $Planet.global_transform.origin
	var up = core_to_mid.normalized()
	
	var from = $Planet.global_transform.origin
	var to = up * 1000
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		if $Planet.get_instance_id() != result.collider_id:
			print("Woah, what are you shooting at? We'll consider this a misfire.")
			return
		
		var height_from_core = (result.position - from).length()
		
		# How high above the surface do we want the missile?
		height_from_core += surface_missile_height
		
		var height_from_mid = height_from_core - core_to_mid.length()
		
		# Create a new surface missile
		var missile = surface_missile_scene.instance()
		missile.init(start, end, from, height_from_mid)
		add_child(missile)

func spawn_humans():
	var aabb = $Planet.get_bounding_box()
	var radius = aabb.size.length() / 2
	
	for i in range(num_humans):
		var spawn_point = random_point_on_sphere(radius)
		
		var human = human_scene.instance()
		human.translate(spawn_point)
		
		human.planet_path = $Planet.get_path()
		human.planet = $Planet
		human.alien_path = $Player.get_path()
		human.alien = $Player
		#print(human.alien)
		add_child(human)

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
