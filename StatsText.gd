extends Label

const format = "Deaths: %s\nShields: %s\n"

onready var prev_num_shields = GlobalStats.num_shields

func _process(delta):
	if prev_num_shields < GlobalStats.num_shields:
		$BlingBling.emitting = true
	prev_num_shields = GlobalStats.num_shields
	
	var s = ""
	
	s += "Population: %s\n" % GlobalStats.population
	s += "Deaths: %s\n" % GlobalStats.deaths
	s += "Shields: %s" % GlobalStats.num_shields

	text = s
