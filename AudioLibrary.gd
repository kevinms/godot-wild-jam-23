extends Node

var human_noises = []

func random_human_noise():
	return human_noises[randi() % human_noises.size()]

# Called when the node enters the scene tree for the first time.
func _ready():
	human_noises = load_directory("res://assets/audio/clips/")

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
