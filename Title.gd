extends Spatial

func _ready():
	$"FakePlayer/AnimationPlayer".play("run-loop")

var state = 0

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		Global.goto_scene("res://Intro.tscn")

#	if !$AnimationPlayer.is_playing():
#		Global.goto_scene("res://MainMenu.tscn")
