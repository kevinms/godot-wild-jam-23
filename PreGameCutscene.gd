extends Spatial

func _ready():
#	$"Arrival/prop-planet/AnimationPlayer".play()
#	$"Arrival/prop-ufo/AnimationPlayer".play()
#
#	$"Greeting/alien-03/AnimationPlayer".play("idle-loop")
#
#	$"A New Friend/prop-text-8-a-new-friend/AnimationPlayer".play("upy-downy")
#
#	$"NotThisTime/prop-text-9-not-this-time/AnimationPlayer".play("pulsey-pulsey")
	
	$AnimationPlayer.play("lolololol")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		Global.goto_scene("res://Game.tscn")

	if !$AnimationPlayer.is_playing():
		Global.goto_scene("res://Game.tscn")
