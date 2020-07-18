extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
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
	
	fire_missile_occasionally(delta)
	
	#occasionally_fire_surface_missile()

	spawn_every_n_seconds(delta)

var since_spawn_sec: float = 0.0
var spawn_interval_sec: float = 3.0
func spawn_every_n_seconds(delta):
	since_spawn_sec += delta
	if since_spawn_sec > spawn_interval_sec:
		spawn_powerup()
		since_spawn_sec = 0.0

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

func pick_surface_missile_source_target():
	var all_humans = get_tree().get_nodes_in_group("humans")
	var population = all_humans.size()
	
	# Pick a source human	
	var which = randi() % population
	var source = all_humans[which]
	
	# Pick a target human
	which = randi() % population
	var target = all_humans[which]
	if target == source:
		which = (which+1)%population
		target = all_humans[which]
	
	var launch_site = nearest_surface_point(source.global_transform.origin)
	var impact_site = nearest_surface_point(target.global_transform.origin)
	launch_surface_missile(launch_site, impact_site)

func launch_surface_missile(start: Vector3, end: Vector3):
	if start == Vector3.ZERO or end == Vector3.ZERO:
		return
	
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
		
		var max_sound_dist = 12.0
		var min_sound_dist = 4.0
		
		var dist = ($Player.global_transform.origin - start).length()
		if dist > min_sound_dist:
			#var norm_dist = 1.0 - (dist - min_sound_dist / max_sound_dist - min_sound_dist)
			
			var norm_dist = 1.0 - clamp((dist - min_sound_dist) / (max_sound_dist - min_sound_dist), 0.0, 1.0)
			
			print(norm_dist)
			missile.sound_db = range_lerp(norm_dist, 0.0, 1.0, -12.0, 0.0)
			print("sound db: ", missile.sound_db)
		
		missile.init(start, end, from, height_from_mid)
		add_child(missile)
		
		missile.connect("surface_missile_impact", $Planet, "_on_Emitter_surface_missile_impact")
		missile.connect("surface_missile_impact", self, "_on_Emitter_surface_missile_impact")

func nearest_surface_point(pos: Vector3, height: float = 0.0):
	var up = (pos - $Planet.global_transform.origin).normalized()
	
	var from = $Planet.global_transform.origin
	var to = up * 1000
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		if $Planet.get_instance_id() != result.collider_id:
			print("Woah, what are you shooting at? We'll consider this a misfire.")
			return Vector3.ZERO
		
		print("new pos")
		return result.position + (up * height)
	return Vector3.ZERO

func _on_Emitter_surface_missile_impact(impact_site, blast_radius):
	print("impact_site ", impact_site, " blast_raduis ", blast_radius)
	
	var space_state = get_world().direct_space_state
	
	# Create the intersection shape
	var sphere = SphereShape.new()
	sphere.radius = 3.0
	
	# Configure the query parameters
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(sphere)
	#query.set_transform(get_transform())
	
	query.transform = Transform(Basis.IDENTITY, impact_site)
	#query.set_exclude(excludes)
	
	var max_results = 32
	var results = space_state.intersect_shape(query, max_results)
	
	for result in results:
		var collider = result["collider"]
		if collider == $Planet:
			continue
		if collider.name == "Player":
			print("Ouchie")
			GlobalStats.health -= 10
		else:
			if collider.get_groups().find("humans") >= 0:
				GlobalStats.population -= 1
				collider.queue_free()

#func _on_Emitter_launch_surface_missile(launch_site, human):
#	print("Launch me!")
#	var all_humans = get_tree().get_nodes_in_group("humans")
#
#	# Pick a target human
#	var population = all_humans.size()
#	var which = randi() % population
#	var target = all_humans[which]
#	if target == human:
#		which = (which+1)%population
#
#	var impact_site = target.global_transform.origin
#	launch_surface_missile(launch_site, impact_site)

var launch_interval_sec = 10.0

var next_fire: float
var sec_elapsed = 0.0
func fire_missile_occasionally(delta):
	sec_elapsed += delta
	if sec_elapsed < next_fire:
		return
	
	#fire_missile()
	pick_surface_missile_source_target()
	
	next_fire = rand_range(0, launch_interval_sec)
	sec_elapsed = 0

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
		
		GlobalStats.population += 1
		
		human.connect("launch_surface_missile", self, "_on_Emitter_launch_surface_missile")

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


func _on_Game_tree_exited():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

onready var shield_scene = load("res://ShieldPickup.tscn")

func spawn_powerup():
	var spawn_point = random_point_on_sphere(1.0)
	spawn_point = nearest_surface_point(spawn_point, 1.0)
	
	print("power up ", spawn_point)
	
	if spawn_point == Vector3.ZERO:
		print("whhhhhhhhhhaaaaaaaatt??!?!?!")
		return

	var pickup = shield_scene.instance()
	#pickup.global_transform.origin = spawn_point
	pickup.translate(spawn_point)
	add_child(pickup)
