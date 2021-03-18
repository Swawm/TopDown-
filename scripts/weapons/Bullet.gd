extends Area2D
class_name Bullet

export (int) var speed = 5

var direction := Vector2.ZERO
onready var timer = $KillTimer

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity
		
	
func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()
	
func _on_KillTimer_timeout() -> void:
	queue_free()

func _ready() -> void:
	timer.start()


func _on_Bullet_body_entered(body: Node) -> void:
	if body.has_method("handle_hit"):
		$hit_flesh.play()
		$Sprite.set_visible(false)
		$blood_particle.set_emitting(true)
		yield($hit_flesh, "finished")
		body.handle_hit()
	else:
		speed = 0
		$Sprite.set_visible(false)
		$wall_particle.set_emitting(true)
		$hit_wall.play()
		yield ($hit_wall, "finished")
	queue_free()
	

