extends HBoxContainer

# If I magically find time, I can split music from sfx and do this:
# https://godotengine.org/qa/24377/change-global-volume-in-3-0

func _ready():
	$Slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

func _on_Slider_value_changed(value):
	print("Volume ", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
