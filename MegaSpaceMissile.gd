extends KinematicBody

var speed: float = 19

var max_distance: float = 1000.0
var start: Vector3
var dir: Vector3

var blast_radius: float = 4.0
var impacted = false

var sound = true
var sound_db = 0.0

func _ready():
	start = global_transform.origin
	$Existance.play("existance")
	$Alarm.play()

func _physics_process(delta):
	if $Death/DeathTimer.time_left > 0 and $Death/DeathTimer.time_left < 0.5:
		$MeshInstance.visible = false
	if $Neutralize/NeutralizeTimer.time_left > 0 and $Neutralize/NeutralizeTimer.time_left < 0.5:
		$MeshInstance.visible = false
	
	if impacted:
		return
	
	var dist = (global_transform.origin - start).length()
	if dist > max_distance:
		queue_free()
		return
	
	var velocity_delta = dir.normalized() * speed * delta

	var collision = move_and_collide(velocity_delta)
	if collision:
		# Deploy shield
		if collision.collider.is_in_group("shield"):
			neutralize()
		else:
			print("we hit the world!!!! ", collision.position)
			explode(collision.position)

signal surface_missile_impact(impact_site, blast_radius)

func emit_surface_missile_impact_signal(impact_site, blast_radius):
	print("emitting signal")
	emit_signal("surface_missile_impact", impact_site, blast_radius)


func explode(impact_site: Vector3 = Vector3.ZERO):
	if impacted:
		return
	impacted = true
	
	$MeshInstance/Particles.emitting = false
	#$MeshInstance.visible = false
	$CollisionShape.disabled = true
	$Death/DeathParticles.emitting = true
	$Death/DeathTimer.start()
	if !sound:
		# We rely on the sound finishing to free the object so let it play but essentially mute it.
		$Death/DeathSound.volume_db = -80.0
	$Death/DeathSound.play()
	
	#var up = (global_transform.origin - core).normalized()
	#$Explosion.pwrocess_material.initial_
	
	if impact_site == Vector3.ZERO:
		print("unknown impact_site")
		impact_site = global_transform.origin
	
	emit_surface_missile_impact_signal(impact_site, blast_radius)

func _on_DeathTimer_timeout():
	$Death/DeathParticles.emitting = false
	$Death/DeathSound.playing = false
	queue_free()


func neutralize():
	if impacted:
		return
	impacted = true
	
	GlobalStats.score += 500
	
	$MeshInstance/Particles.emitting = false
	#$MeshInstance.visible = false
	$CollisionShape.disabled = true
	$Neutralize/NeutralizeParticles.emitting = true
	$Neutralize/NeutralizeTimer.start()
	$Neutralize/NeutralizeSound.play()

func _on_NeutralizeSound_finished():
	$Neutralize/NeutralizeParticles.emitting = false
	$Neutralize/NeutralizeSound.playing = false
	queue_free()
