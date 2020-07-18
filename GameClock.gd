extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = GlobalStats.game_time
	
	var seconds = floor(t)
	var minutes = t / 60.0
	
	var s = ""
	s += "Time Survived:\n"
	s += "      %d:%02d" % [minutes, seconds]
	text = s
