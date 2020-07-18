extends Spatial

func _ready():
	$"Arrival/prop-planet/AnimationPlayer".play()
	$"Arrival/prop-ufo/AnimationPlayer".play()
	
	$"Greeting/alien-03/AnimationPlayer".play("idle-loop")
	
	$"Bike/alien-03/AnimationPlayer".play("idle-loop")
	
	$"Later/prop-later-text/AnimationPlayer".play("later-anim")
	
	$"Death/alien-04/AnimationPlayer".play("jump")
	
	$"NeverAgain/prop-text-7-never-again/AnimationPlayer".play("never-again-pulse")

var state = 0

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		Global.goto_scene("res://MainMenu.tscn")
	
	if $Camera/AnimationPlayer.is_playing():
		return
	
	if state == 0:
		state += 1
		$Camera/AnimationPlayer.play("first-half")
	elif state == 1:
		state += 1
		$Camera/AnimationPlayer.play("second-half")
	elif state == 2:
		state += 1
		$Camera/AnimationPlayer.play("destruction-anim")
	elif state == 3:
		state += 1
		$Camera/AnimationPlayer.play("final")
	elif state == 4:
		state += 1
		Global.goto_scene("res://MainMenu.tscn")
