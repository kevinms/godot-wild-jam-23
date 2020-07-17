extends Spatial

func _ready():
	$"Arrival/prop-planet/AnimationPlayer".play()
	$"Arrival/prop-ufo/AnimationPlayer".play()
	
	$"Greeting/alien-03/AnimationPlayer".play("idle-loop")
	
	$"A New Friend/prop-text-8-a-new-friend/AnimationPlayer".play("upy-downy")
	
	$"NotThisTime/prop-text-9-not-this-time/AnimationPlayer".play("pulsey-pulsey")
	
	$Camera/AnimationPlayer.play("cutscene")
