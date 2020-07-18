extends Node

var humans_to_spawn = 100

var health = 100
var population = 0
var deaths = 0

var num_shields: int = 1

var mouse_sensitivity: float = 0.00098 # radians / pixel


func reset():
	humans_to_spawn = 100
	health = 100
	population = 0
	deaths = 0
	num_shields = 1
