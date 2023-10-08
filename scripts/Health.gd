extends Node2D

@export var health : int = 10 : get = _get_health, set = _set_health


func _set_health(new_health: int):
	health = clamp(new_health, 0, 100)
	
func _get_health():
	return health
