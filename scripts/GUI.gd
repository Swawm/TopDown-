extends CanvasLayer

@onready var health_bar = $MarginContainer/Rows/BottomRow/Health
@onready var current_ammo_bar = $MarginContainer/Rows/BottomRow/CurrentAmmo
@onready var total_ammo_bar = $MarginContainer/Rows/BottomRow/TotalAmmo

var player: Player
var weapon_manager: WeaponManager

func set_player(player):
	self.player = player
	set_new_health_value(player.health_stat.health)
	player.connect("player_health_changed",Callable(self,"set_new_health_value"))
	player.weapon.connect("weapon_changed",Callable(self,"set_gun"))
	set_gun(player.weapon.get_current_weapon())


func set_gun(_weapon: Weapon):
	set_current_ammo_value(player.weapon.current_weapon.current_ammo)
	set_total_ammo_value(player.weapon.current_weapon.max_ammo)
	player.weapon.current_weapon.connect("weapon_ammo_changed",Callable(self,"set_current_ammo_value"))


func set_new_health_value(new_health: int):
	health_bar.set_value(new_health)

func set_current_ammo_value(new_current_ammo: int):
	current_ammo_bar.text = str(new_current_ammo)

func set_total_ammo_value(new_total_ammo: int):
	total_ammo_bar.text = str(new_total_ammo)
