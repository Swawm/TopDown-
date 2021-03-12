extends Node2D
class_name Weapon

signal weapon_out_of_ammo


export (PackedScene) var Bullet  

export (int) var max_ammo: int = 7
export (bool) var automatic: bool = false
export (float) var bullet_speed: int =  0 
var current_ammo: int = max_ammo



onready var end_of_gun = $EndGun
onready var attack_cooldown = $AttackCooldown
onready var animation = $AnimationPlayer
onready var shoot_sound = $ShootSound
onready var empty_shoot_sound = $EmptySound
onready var reload_sound = $ReloadSound
onready var muzzle = $MuzzleFlash

var shooting

func _ready():
	muzzle.hide()
	current_ammo = max_ammo

func shoot():
	if current_ammo !=0 and attack_cooldown.is_stopped() and Bullet != null and !animation.is_playing():
		shooting = true
		var bullet_instance = Bullet.instance()
		var direction = (end_of_gun.global_position - global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction, bullet_speed)
		attack_cooldown.start()
		animation.play("muzzle_flash")
		shoot_sound.play()
		current_ammo -= 1
		if current_ammo == 0:
			emit_signal("weapon_out_of_ammo")
	if current_ammo == 0 and attack_cooldown.is_stopped():
		empty_shoot_sound.play()

			
		 
func start_reload():
	if !animation.is_playing():
		animation.play("reload")
		reload_sound.play()

	
func _stop_reload():
	current_ammo = max_ammo
