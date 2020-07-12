extends Position3D

export var mouse_sensitivity = 0.002 # radians / pixel
export var zoom_sensitivity = 0.1

onready var min_dist = $Camera.translation.normalized() * 5
onready var max_dist = $Camera.translation.normalized() * 20

func _unhandled_input(event):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		var angle = -event.relative.y * mouse_sensitivity
		rotate_object_local(Vector3.RIGHT, angle)
	elif event is InputEventMouseButton:
		print(typeof(event))
		if event.button_index == BUTTON_WHEEL_UP:
			var camera_pos = $Camera.transform.origin
			$Camera.transform.origin = camera_pos.move_toward(min_dist, camera_pos.length() * zoom_sensitivity)
		if event.button_index == BUTTON_WHEEL_DOWN:
			var camera_pos = $Camera.transform.origin
			$Camera.transform.origin = camera_pos.move_toward(max_dist, camera_pos.length() * zoom_sensitivity)
