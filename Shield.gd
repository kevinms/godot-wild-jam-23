extends Spatial

func _ready():
	$Particles.emitting = true

func _on_DurationTimer_timeout():
	$Drop.play()


func _on_Drop_finished():
	queue_free()

func _on_Shield_body_entered(body):
	if body.is_in_group("missile"):
		print("Shield hit detected!!!!!!!!!!!!!")
