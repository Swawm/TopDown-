extends Node2D
class_name Map_AI

enum BaseCaptureOrder{
	FIRST,
	LAST

}

@export var base_capture_start_order: BaseCaptureOrder
@export  var team_name: Team.TeamName = Team.TeamName.NEUTRAL
@export  var unit: PackedScene = null
@export  var max_units_alive: int = 250

@onready var team = $Team
@onready var unit_container = $UnitContainer
@onready var respawn_timer = $RespawnTimer

var target_base: CapturableBase = null
var capturable_bases: Array = []
var respawn_points: Array = []
var next_spawn_to_use: int = 0
var pathfinding : Pathfinding

func initialize(capturable_bases: Array, respawn_points: Array, pathfinding: Pathfinding):
	if capturable_bases.size() == 0 or respawn_points.size() == 0 or unit == null:
		push_error("lol ur fukd")
		return
	team.team = team_name
	self.pathfinding = pathfinding
	


	self.capturable_bases = capturable_bases
	self.respawn_points = respawn_points
	for respawn in respawn_points:
		spawn_unit(respawn.global_position)
	for base in capturable_bases:
		base.connect("base_captured",Callable(self,"handle_base_captured"))

	check_for_next_capturable_bases()

func handle_base_captured(_new_team: int):
	check_for_next_capturable_bases()

func check_for_next_capturable_bases():
	var next_base = get_next_capturable_base()
	if next_base != null:
		target_base = next_base
		assign_next_capturable_base(next_base)

func get_next_capturable_base():
	var list_of_bases = range(capturable_bases.size())
	if base_capture_start_order == BaseCaptureOrder.LAST:
		list_of_bases = range(capturable_bases.size() -1, -1, -1)

	for i in list_of_bases:
		var base: CapturableBase = capturable_bases[i]
		if team.team != base.team.team:
			return base

	return null

func assign_next_capturable_base(base: CapturableBase):
	for unit in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)

func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instantiate()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died",Callable(self,"handle_unit_death"))
	unit_instance.ai.pathfinding = pathfinding
	set_unit_ai_to_advance_to_next_base(unit_instance)

func set_unit_ai_to_advance_to_next_base(unit: Actor):
	if target_base != null and unit != null:
		var ai: AI = unit.ai
		print(ai)
		ai.next_base = target_base.get_random_position_within_capture_radius()
		ai.set_state(AI.State.ADVANCING)


func handle_unit_death():
	if respawn_timer.is_stopped() and unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()

func _on_RespawnTimer_timeout():
	var respawn = respawn_points[next_spawn_to_use]
	spawn_unit(respawn.global_position)
	next_spawn_to_use +=1
	if next_spawn_to_use == respawn_points.size():
		next_spawn_to_use = 0
	if unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()
