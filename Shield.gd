extends Spatial

func _ready():
	$Particles.emitting = true

func _on_DurationTimer_timeout():
	$Mesh.visible = false
	$CollisionShape.disabled = true
	$Down.play()

func _on_Down_finished():
	queue_free()

func _on_Shield_body_entered(body):
	if !body.is_in_group("missile"):
		push_error("test error")
