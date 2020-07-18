extends HBoxContainer

#export var mouse_sensitivity = 0.002 # radians / pixel

# Extents in radians / pixel
const min_rad: float = 0.003
const max_rad: float = 0.03

func _ready():
	var mapped = lerp(0.0, 100.0, GlobalStats.mouse_sensitivity * 10.0 / (max_rad - min_rad))
	#print("initial: ", GlobalStats.mouse_sensitivity, " mapped:  ", mapped)
	$Slider.value = mapped

func _on_Slider_value_changed(value):
	var mapped = lerp(min_rad, max_rad, value / 100.0)
	#print("sensitivity: ", value, " mapped: ", mapped)
	
	GlobalStats.mouse_sensitivity = mapped / 10.0
