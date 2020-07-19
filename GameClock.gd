extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GlobalStats.player_dieing or GlobalStats.player_dead or GlobalStats.game_over:
		return
	
	var t = GlobalStats.game_time
	
	var seconds = fmod(t, 60.0)#floor(t)
	var minutes = t / 60.0
	
	var s = ""
	s += "Time Survived:\n"
	s += "      %d:%02d" % [minutes, seconds]
	text = s
