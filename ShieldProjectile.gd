extends KinematicBody

var speed: float = 20

var max_distance: float = 200.0
var start: Vector3
var dir: Vector3

func _ready():
	start = global_transform.origin
	$Fire.play()

func _physics_process(delta):
	
	var dist = (global_transform.origin - start).length()
	if dist > max_distance:
		queue_free()
		return
	
	var velocity_delta = dir.normalized() * speed * delta

	var collision = move_and_collide(velocity_delta)
	if collision:
		# Deploy shield
		deploy()

onready var shield_scene = load("res://Shield.tscn")
signal deploy_shield(global_point)

func deploy():
	emit_signal("deploy_shield", global_transform.origin)
	queue_free()

func _on_AudioStreamPlayer_finished():
	$Fire.playing = false
