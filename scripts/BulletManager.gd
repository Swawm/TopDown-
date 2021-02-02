extends Node2D


func handle_bullet_spawned(bullet: Bullet, position: Vector2, direction: Vector2, bullet_speed: int):
	add_child(bullet)
	bullet.speed = bullet_speed
	bullet.global_position = position
	bullet.set_direction(direction)
