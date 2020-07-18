extends Node

var humans_to_spawn = 100

var health: int = 100
var population: int = 0
var deaths: int = 0

var num_shields: int = 1

var mouse_sensitivity: float = 0.00098 # radians / pixel
var game_time: float = 0.0

func reset():
	humans_to_spawn = 100
	health = 100
	population = 0
	deaths = 0
	num_shields = 1
	game_time = 0.0

func _process(delta):
	game_time += delta
