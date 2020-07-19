extends KinematicBody

var start: Vector3
var end: Vector3
var core: Vector3
var height_from_mid: float
var speed: float
var blast_radius: float

var sound = true
var sound_db = 0.0

func init(start: Vector3, end: Vector3, core: Vector3, height_from_mid: float):
	self.start = start
	self.end = end
	self.core = core
	self.height_from_mid = height_from_mid
	
	self.speed = 0.2
	self.blast_radius = 1.0
	
	$Particles.emitting = true
	
	if sound and randf() < 1.1:
		$Launch.volume_db = sound_db
		$Launch.play()

signal surface_missile_impact(impact_site, blast_radius)

func emit_surface_missile_impact_signal(impact_site, blast_radius):
	print("emitting signal")
	emit_signal("surface_missile_impact", impact_site, blast_radius)

var impacted = false
var at_end = false

var t = 0
func _physics_process(delta):
	#var world_up = (global_transform.origin - core).normalized()

	#var xform = align_with_y(global_transform, world_up)
	#global_transform = global_transform.interpolate_with(xform, 1.0)
	
	if impacted:
		return
	
	#update_end_point()
	
	#t = clamp(t + delta, 0, 1.0)
	t = clamp(t + speed * delta, 0, 1.0)
	
	var new_global_origin = global_transform.origin
	if !at_end:
		new_global_origin = sine_lerp(t)
		if t >= 1.0:
			at_end = true
	
	var dist_from_start = global_transform.origin - start
	if t > 0.3:
		var velocity_delta = new_global_origin - global_transform.origin
		var collision = move_and_collide(velocity_delta)
		if collision:
			explode()
			
	else:
		global_transform.origin = new_global_origin

func explode():
	if impacted:
		return
	impacted = true
	
	$Particles.emitting = false
	$MeshInstance.visible = false
	$CollisionShape.disabled = true
	$Death/DeathParticles.emitting = true
	$Death/DeathTimer.start()
	$Death/DeathSound.play()
	
	#var up = (global_transform.origin - core).normalized()
	#$Explosion.pwrocess_material.initial_
	
	emit_surface_missile_impact_signal(end, blast_radius)

#func update_end_point():
#	# Shoot a ray towards the planet and see what is in the way.
#	var from = global_transform.origin
#	var to = global_transform.origin + (dir * 10.0)
#
#	var space_state = get_world().direct_space_state
#	var result = space_state.intersect_ray(from, to, [self])
#
#	if !result:
#		# Rotate a little counter-clockwise and try again
#		dir = dir.rotated(global_transform.basis.y, rand_range(0, PI/2)).normalized()
#	elif result.collider == planet:
#		# This looks safe-ish...
#		print("Safe direction!")
#		return dir
#
#	return Vector3.ZERO

# 0 to 1
func sine_lerp(t: float):
	var x = lerp(0, PI, t)
	var unit_height = sin(x)
	
	var height = height_from_mid * unit_height
	
	var spot = start.linear_interpolate(end, t)
	var mid = start.linear_interpolate(end, 0.5)
	var dir = (mid - core).normalized()
	
	return spot + (dir * height)
	
	#var spot = start.linear_interpolate(end, t)
	#var ray = spot - core
	#ray = ray.normalized() * (ray.length() + height)
	#return core + ray

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _on_DeathTimer_timeout():
	$Death/DeathParticles.emitting = false
	queue_free()
