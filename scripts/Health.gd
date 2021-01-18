extends Node2D

export (int) var health = 10 setget set_health


func set_health(new_health: int):
	health = clamp(new_health, 0, 100)
	
