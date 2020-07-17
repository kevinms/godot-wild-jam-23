extends Spatial

func _ready():
	$"Arrival/prop-planet/AnimationPlayer".play()
	$"Arrival/prop-ufo/AnimationPlayer".play()
	
	$"Greeting/alien-03/AnimationPlayer".play("idle-loop")
	
	$"Bike/alien-03/AnimationPlayer".play("idle-loop")
	
const ST_FIRST = 1
const ST_SECOND = 2
const ST_FINAL = 3

var state = 0

func _process(delta):
	if $Camera/AnimationPlayer.is_playing():
		return
	
	if state == 0:
		state = 1
		$Camera/AnimationPlayer.play("first-half")
	elif state == 1:
		state = 2
		$Camera/AnimationPlayer.play("second-half")
	elif state == 2:
		state = 3
		$Camera/AnimationPlayer.play("final")
