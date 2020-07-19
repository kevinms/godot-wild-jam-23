extends Spatial

func _ready():
	$Particles.emitting = true

func _on_DurationTimer_timeout():
	$Mesh.visible = false
	$CollisionShape.disabled = true
	$Down.play()

func _on_Down_finished():
	queue_free()

func neutralize_missile(missile):
	missile.neutralize()

func _physics_process(delta):
	var space_state = get_world().direct_space_state
	
	# Create the intersection shape
	var sphere = SphereShape.new()
	sphere.radius = $CollisionShape.shape.radius
	
	# Configure the query parameters
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(sphere)
	query.transform = Transform(Basis.IDENTITY, global_transform.origin)
	#query.set_exclude(excludes)
	
	var max_results = 5
	var results = space_state.intersect_shape(query, max_results)
	
	for result in results:
		var collider = result["collider"]
		
		if collider.is_in_group("missile"):
			neutralize_missile(collider)

func _on_Shield_body_entered(body):
	if body.is_in_group("missile"):
		neutralize_missile(body)
