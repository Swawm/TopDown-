extends Node2D

@onready var bullet_manager = $BulletManager
@onready var capturable_base_manager = $CapturableBaseManager
@onready var ally_AI = $AllyMapAI
@onready var enemy_AI = $EnemyMapAI
@onready var camera = $Camera2D
@onready var ground = $Ground
@onready var pathfinding = $Pathfinding
@onready var gui = $GUI

const Player = preload("res://scenes/actors/humans/Player.tscn")

func _ready() -> void:
	randomize()
	GlobalSignals.connect("bullet_fired",Callable(bullet_manager,"handle_bullet_spawned"))
	
	pathfinding.create_navigation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	ally_AI.initialize(bases, ally_respawns.get_children(), pathfinding)
	enemy_AI.initialize(bases, enemy_respawns.get_children(), pathfinding)
	spawn_player()
	debug()
	
	
	
func spawn_player():
	var player = Player.instantiate()
	player.global_position = $PlayerSpawn.global_position
	add_child(player)
	player.set_camera_transform(camera.get_path())
	player.connect("died",Callable(self,"spawn_player"))
	gui.set_player(player)
	
func debug():
	var overlay = load("res://scenes/debug_overlay.tscn").instantiate()
	overlay.add_stat("FPS", Engine, "get_frames_per_second", true )
	add_child(overlay)
