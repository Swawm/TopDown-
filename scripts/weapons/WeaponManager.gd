extends Node2D
class_name WeaponManager

signal weapon_changed (current_weapon)

onready var current_weapon: Weapon = $Pistol
onready var sound = $ChangeSound
var weapons: Array = []


func _ready():
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()

	current_weapon.show()


func initialize(team: int) -> void:
	for weapon in weapons:
		weapon.initialize(team)
	
func reload():
	current_weapon.start_reload()

func _unhandled_input(event: InputEvent) -> void:
	if current_weapon.automatic == false and event.is_action_pressed("shoot"):
		current_weapon.shoot()
	if event.is_action_pressed("reload"):
		current_weapon.start_reload()
	if !current_weapon.animation.is_playing():
		if event.is_action_pressed("weapon_1"):
			switch_weapon(weapons[0])
		if event.is_action_pressed("weapon_2"):
			switch_weapon(weapons[1])
		if event.is_action_pressed("weapon_3"):
			switch_weapon(weapons[2])

func _process(delta):
	if current_weapon.automatic and Input.is_action_pressed("shoot"):
		current_weapon.shoot()

func switch_weapon(weapon: Weapon):
	if weapon == current_weapon:
		return
	current_weapon.hide()
	weapon.show()
	sound.play()
	current_weapon = weapon
	emit_signal("weapon_changed", current_weapon)
	
func get_current_weapon():
	return current_weapon
