extends HBoxContainer

func _ready():
	$CheckBox.pressed = OS.window_fullscreen

func _on_CheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
