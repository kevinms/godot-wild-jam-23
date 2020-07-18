extends Spatial

export var start_blinking_sec: float = 2.0
var blink = false

#var pos: Vector3
#func _ready():
#	pos = global_transform.origin
#func _physics_process(delta):
#	global_transform.origin = pos

func _process(delta):
	if !blink and $Timer.time_left < start_blinking_sec:
		blink = true
		$Blink.play("blink")

func _on_Expire_timeout():
	queue_free()

func _on_ShieldPickup_body_entered(body):
	GlobalStats.num_shields += 1
	$Blink.stop()
	$CollisionShape.disabled = true
	$VisibleStuff/MeshInstance.visible = false
	$VisibleStuff/Particles.emitting = false

	$Explosion/Sound.play()
	$Explosion/Particles.emitting = true

func _on_Sound_finished():
	queue_free()
