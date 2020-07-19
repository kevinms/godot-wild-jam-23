extends Node

var humans_to_spawn = 100

var health: int = 100
var population: int = 0
var deaths: int = 0

var num_shields: int = 6

var mouse_sensitivity: float = 0.00098 # radians / pixel
var game_time: float = 0.0

var player_dieing = false
var player_dead = false
var game_over = false

var score: int = 0

# 10 is fairly slow
# 5 can't protect them all with this
# Scale this for difficulty
var launch_interval_sec = 10.0

func reset():
	humans_to_spawn = 100
	
	health = 100
	population = 0
	deaths = 0
	
	num_shields = 6
	
	game_time = 0.0
	
	player_dieing = false
	player_dead = false
	game_over = false
	
	launch_interval_sec = 5.0
	
	score = 0

func _process(delta):
	game_time += delta
