extends Node

var human_noises = []
var beep_noises = []

func random_human_noise():
	return human_noises[randi() % human_noises.size()]

func random_beep_noise():
	return beep_noises[randi() % beep_noises.size()]

# Called when the node enters the scene tree for the first time.
func _ready():
	#human_noises = load_directory("res://assets/audio/clips/")
	#beep_noises = load_directory("res://assets/sfx/beep/")
	load_human_noises()
	load_beep_noises()
	
	print(human_noises)

func load_beep_noises():
	beep_noises.append(load("res://assets/sfx/beep/1.wav"))
	beep_noises.append(load("res://assets/sfx/beep/2.wav"))
	beep_noises.append(load("res://assets/sfx/beep/3.wav"))
	beep_noises.append(load("res://assets/sfx/beep/4.wav"))
	beep_noises.append(load("res://assets/sfx/beep/5.wav"))

func load_human_noises():
	human_noises.append(load("res://assets/audio/clips/ahhh-0.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-00.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-01.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-02.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-03.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-04.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-05.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-06.wav"))
	human_noises.append(load("res://assets/audio/clips/ahhh-07.wav"))
	human_noises.append(load("res://assets/audio/clips/aliens-00.wav"))
	human_noises.append(load("res://assets/audio/clips/aliens-01.wav"))
	human_noises.append(load("res://assets/audio/clips/aliens-02.wav"))
	human_noises.append(load("res://assets/audio/clips/death-00.wav"))
	human_noises.append(load("res://assets/audio/clips/death-01.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-00.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-01.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-02.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-03.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-04.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-05.wav"))
	human_noises.append(load("res://assets/audio/clips/hehe-06.wav"))
	human_noises.append(load("res://assets/audio/clips/help-me.wav"))
	human_noises.append(load("res://assets/audio/clips/missile-00.wav"))
	human_noises.append(load("res://assets/audio/clips/missile-01.wav"))
	human_noises.append(load("res://assets/audio/clips/missile-02.wav"))
	human_noises.append(load("res://assets/audio/clips/missile-03.wav"))
	human_noises.append(load("res://assets/audio/clips/missile-04.wav"))
	human_noises.append(load("res://assets/audio/clips/run-away-00.wav"))
	human_noises.append(load("res://assets/audio/clips/run-away-01.wav"))


# WHY DOES THIS METHOD NOT WORKING WHEN EXPROTING THE GAME TO A PACKAGE?!?!?!
# OMG!!!!
func load_directory(directory_path: String):
	var directory = Directory.new()
	directory.open(directory_path)
	directory.list_dir_begin(true)
	
	var sounds = []
	var file = directory.get_next()
	while file != "":
		print(file)
		var res = load(directory_path + file)
		if res:
			sounds.append(res)
		file = directory.get_next()
	return sounds
