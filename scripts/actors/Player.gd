extends KinematicBody2D
class_name Player

signal died 
signal player_health_changed(new_health)

export (int) var speed = 100



onready var health_stat = $Health
onready var weapon = $Weapon
onready var team = $Team
onready var remote_transform = $CameraTransform
onready var anim = $AnimationPlayer
onready var collision = $CollisionShape2D		


func _physics_process(delta) -> void:
	
	var movement_direction := Vector2.ZERO
	if Input.is_action_pressed("up"):
		movement_direction.y = -1
		anim.play("run")
	if Input.is_action_pressed("left"):
		movement_direction.x = -1
		anim.play("run")
	if Input.is_action_pressed("down"):
		movement_direction.y = 1
		anim.play("run")
	if Input.is_action_pressed("right"):
		movement_direction.x = 1
		anim.play("run")
	if Input.is_action_pressed("run"):
		speed = 200
		anim.set_speed_scale(2)
	else:
		speed = 100
		anim.set_speed_scale(1)

	movement_direction = movement_direction.normalized()
	move_and_slide(movement_direction * speed)

	look_at(get_global_mouse_position())

func initialize():
	weapon.initialize()
	
func handle_hit() -> void:
	health_stat.health -= 20
	emit_signal("player_health_changed", health_stat.health)
	if health_stat.health <= 0:
		die()
		pass
		
func get_team() -> int:
	return team.team
	
func set_camera_transform(camera_path: NodePath):
	remote_transform.remote_path = camera_path

func die():
	emit_signal("died")
	queue_free()
