extends Node

var human_noises = []
var beep_noises = []

func random_human_noise():
	return human_noises[randi() % human_noises.size()]

func random_beep_noise():
	return beep_noises[randi() % beep_noises.size()]

# Called when the node enters the scene tree for the first time.
func _ready():
	human_noises = load_directory("res://assets/audio/clips/")
	beep_noises = load_directory("res://assets/sfx/beep/")

func load_directory(directory_path: String):
	var directory = Directory.new()
	directory .open(directory_path)
	directory.list_dir_begin(true)
	
	var sounds = []
	var file = directory.get_next()
	while file != "":
		print(file)
		sounds.append(load(directory_path + "/" + file))
		file = directory.get_next()
	return sounds
