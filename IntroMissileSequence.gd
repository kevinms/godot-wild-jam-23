extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():	
	spawn_humans()

const ray_length = 1000
export var num_humans = 100
onready var human_scene = load("res://Human.tscn")


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
		
		missile.connect("surface_missile_impact", $Planet, "_on_Emitter_surface_missile_impact")
		missile.connect("surface_missile_impact", self, "_on_Emitter_surface_missile_impact")

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

func _on_Emitter_launch_surface_missile(launch_site, human):
	print("Launch me!")
	var all_humans = get_tree().get_nodes_in_group("humans")
	
	# Pick a target human
	var population = all_humans.size()
	var which = randi() % population
	var target = all_humans[which]
	if target == human:
		which = (which+1)%population
	
	var impact_site = target.global_transform.origin
	launch_surface_missile(launch_site, impact_site)

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

#var next_fire: float
#var sec_elapsed = 0.0
#func fire_missile_occasionally(delta):
#	sec_elapsed += delta
#	if sec_elapsed < next_fire:
#		return
#
#	fire_missile()
#	next_fire = rand_range(0, 1)
#	sec_elapsed = 0

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
