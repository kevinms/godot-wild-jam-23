extends Spatial


func begin_sequence():
	# Fire a bunch of missiles
	pass

func launch_surface_missile(start: Vector3, end: Vector3):
	var mid = start.linear_interpolate(end, 0.5)
	var core_to_mid = mid - $"prop-planet".global_transform.origin
	var up = core_to_mid.normalized()
	
	var from = $"prop-planet".global_transform.origin
	var to = up * 1000
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		if $"prop-planet".get_instance_id() != result.collider_id:
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
