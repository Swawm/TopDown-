extends KinematicBody2D
class_name Player

signal died 

export (int) var speed = 100



onready var health_stat = $Health
onready var weapon = $Weapon
onready var team = $Team
onready var remote_transform = $CameraTransform


func _physics_process(delta) -> void:
	
	var movement_direction := Vector2.ZERO
	if Input.is_action_pressed("up"):
		movement_direction.y = -1
	if Input.is_action_pressed("left"):
		movement_direction.x = -1
	if Input.is_action_pressed("down"):
		movement_direction.y = 1
	if Input.is_action_pressed("right"):
		movement_direction.x = 1
	if Input.is_action_pressed("run"):
		speed = 200
	else:
		speed = 100
 
	movement_direction = movement_direction.normalized()
	move_and_slide(movement_direction * speed)

	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		weapon.shoot()
	if event.is_action_pressed("reload"):
		weapon.start_reload()



	
func handle_hit() -> void:
	health_stat.health -= 20
	if health_stat.health <= 0:
		die()
		
func get_team() -> int:
	return team.team
	
func set_camera_transform(camera_path: NodePath):
	remote_transform.remote_path = camera_path

func die():
	emit_signal("died")
	queue_free()
