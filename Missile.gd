extends KinematicBody

var velocity: Vector3
var target: Spatial
var blast_radius: float

func _ready():
	blast_radius = 1.0

signal missile_impact(impact_site, blast_radius)

func emit_missile_impact_signal(impact_site, blast_radius):
	emit_signal("missile_impact", impact_site, blast_radius)

func _physics_process(delta):
	look_at(target.global_transform.origin, global_transform.basis.y)

	velocity = move_and_slide(velocity)

	for i in get_slide_count():
		print("Missile collided!")
		var collision = get_slide_collision(i)
		emit_missile_impact_signal(collision.position, blast_radius)
		print(collision.collider.name)
