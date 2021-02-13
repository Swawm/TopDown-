extends Node2D

onready var bullet_manager = $BulletManager
onready var capturable_base_manager = $CapturableBaseManager
onready var ally_AI = $AllyMapAI
onready var enemy_AI = $EnemyMapAI
onready var camera = $Camera2D
onready var ground = $Ground
onready var pathfinding = $Pathfinding

const Player = preload("res://scenes/actors/Player.tscn")

func _ready() -> void:
	randomize()
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	
	pathfinding.create_navigation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	ally_AI.initialize(bases, ally_respawns.get_children(), pathfinding)
	enemy_AI.initialize(bases, enemy_respawns.get_children(), pathfinding)
	spawn_player()
	
	
	
func spawn_player():
	var player = Player.instance()
	player.global_position = $PlayerSpawn.global_position
	add_child(player)
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "spawn_player")

