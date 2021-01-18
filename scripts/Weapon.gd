extends Node2D
class_name Weapon

signal weapon_out_of_ammo


export (PackedScene) var Bullet  

var max_ammo: int = 7
var current_ammo: int = max_ammo



onready var end_of_gun = $EndGun
onready var gun_direction = $Gundirection
onready var attack_cooldown = $AttackCooldown
onready var animation = $AnimationPlayer
onready var sound = $ShootSound
onready var muzzle = $MuzzleFlash

func _ready():
	muzzle.hide()


func shoot():
	if current_ammo !=0 and attack_cooldown.is_stopped() and Bullet != null:
		var bullet_instance = Bullet.instance()
		var direction = (gun_direction.global_position - end_of_gun.global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation.play("muzzle_flash")
		sound.play()
		current_ammo -=1
		if current_ammo == 0:
			emit_signal("weapon_out_of_ammo")
		 
func start_reload():
	animation.play("reload")

	
func _stop_reload():
	current_ammo = max_ammo
