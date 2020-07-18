extends PopupPanel

func _ready():
	set_process(true)

func _on_Close_Settings_pressed():
	hide()

var once = false
var saved_mouse_mode

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
#		if !once:
#			saved_mouse_mode = Input.get_mouse_mode()
#			once = true
		saved_mouse_mode = Input.get_mouse_mode()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		popup()
		get_tree().paused = true


func _on_Settings_popup_hide():
	get_tree().paused = false
	Input.set_mouse_mode(saved_mouse_mode)
