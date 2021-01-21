extends KinematicBody2D

onready var health_stat = $Health
onready var ai = $AI
onready var weapon = $Weapon
onready var team = $Team

export (int) var speed = 100

func _ready():
	ai.initialize(self, weapon, team.team)
	pass

func handle_hit() -> void:
	health_stat.health -= 20
	if health_stat.health <=0:
		queue_free()
	pass

func rotate_toward(location: Vector2):
	rotation = lerp(rotation, global_position.direction_to(location).angle(), 0.1)

func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed

func get_team() -> int:
	return team.team