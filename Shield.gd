extends Spatial

var cooldown: float = 4.0
var duration: float = 1.0

func activate():
	if $CooldownTimer.is_stopped():
		$Mesh.show()
		$DurationTimer.start(duration)


func _on_DurationTimer_timeout():
	$Mesh.hide()
	$CooldownTimer.start(cooldown)
