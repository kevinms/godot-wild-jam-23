extends Spatial

const ray_length = 1000

onready var human_scene = load("res://Human.tscn")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = $Camera
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			print("Ray hit: ", result.position)
			
			var closest = $Icosphere.octree.knn(result.position, 32)
			print(closest)

func _ready():
	spawn_humans()

export var num_humans = 100

func spawn_humans():
	var aabb = $Icosphere.get_bounding_box()
	var radius = aabb.size.length() / 2
	
	for i in range(num_humans):
		var spawn_point = random_point_on_sphere(radius)
		
		var human = human_scene.instance()
		human.translate(spawn_point)
		
		human.planet_path = $Icosphere.get_path()
		human.planet = $Icosphere
		human.alien_path = $Player.get_path()
		human.alien = $Player
		print(human.alien)
		add_child(human)

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
