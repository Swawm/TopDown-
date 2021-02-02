extends Node2D

onready var bullet_manager = $BulletManager
onready var capturable_base_manager = $CapturableBaseManager
onready var ally_AI = $AllyMapAI
onready var enemy_AI = $EnemyMapAI
onready var camera = $Camera2D

const Player = preload("res://scenes/Player.tscn")

func _ready() -> void:
	randomize()
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	var bases = capturable_base_manager.get_capturable_bases()
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	ally_AI.initialize(bases, ally_respawns.get_children())
	enemy_AI.initialize(bases, enemy_respawns.get_children())
	spawn_player()
	
	
	
func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "spawn_player")

