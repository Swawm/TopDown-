extends KinematicBody2D
class_name Actor

signal died 


onready var health_stat = $Health
onready var ai = $AI
onready var weapon = $Weapon
onready var team = $Team
onready var anim = $AnimationPlayer
onready var collision = $CollisionShape2D

export (int) var speed = 100

func _ready():
	ai.initialize(self, weapon, team.team)
	pass

func handle_hit() -> void:
	health_stat.health -= 20
	if health_stat.health <=0:
		die()
	pass

func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation, global_position.direction_to(location).angle(), 1)

func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed
	

func get_team() -> int:
	return team.team

func has_reached_position(location: Vector2) -> bool:
	anim.stop()
	return global_position.distance_to(location) < 5
	

func die():
	emit_signal("died")
	queue_free()
	
