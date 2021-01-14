extends Node2D
class_name Weapon


export (PackedScene) var Bullet  


onready var end_of_gun = $EndGun
onready var gun_direction = $Gundirection
onready var attack_cooldown = $AttackCooldown
onready var animation = $AnimationPlayer
onready var sound = $ShootSound

func _ready():
	pass

func shoot():
	if attack_cooldown.is_stopped() and Bullet != null:
		var bullet_instance = Bullet.instance()
		var direction = (gun_direction.global_position - end_of_gun.global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation.play("muzzle_flash")
		sound.play()
