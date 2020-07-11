extends KinematicBody

var velocity: Vector3
var target: Spatial

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	look_at(target.global_transform.origin, global_transform.basis.y)

	move_and_slide(velocity)
