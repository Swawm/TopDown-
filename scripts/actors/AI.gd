extends Node2D
class_name AI

signal state_changed(new_state)

enum State {
	ON_PATROL,
	ENGAGED,
	ADVANCING,
	DEAD,
}

@onready var patrol_timer = $PatrolTimer
@export var vision_core_arc = 60.0

var current_state: int = -1 :
	get:
		return current_state # TODOConverter40 Copy here content of get_state
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_state
var target: CharacterBody2D = null
var weapon: Weapon = null
var actor: Actor = null
var actor_velocity: Vector2 = Vector2.ZERO
var team: int = -1
var pathfinding: Pathfinding
var in_sight : bool
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false
var next_base: Vector2 = Vector2.ZERO
var target_list : Array

func initialize(actor: CharacterBody2D, weapon: Weapon, team: int):
	self.actor = actor
	self.weapon = weapon
	self.team = team
	weapon.connect("weapon_out_of_ammo",Callable(self,"handle_reload"))
	actor.connect("handle_shot",Callable(self,"die"))

func _ready():
	set_state(State.ON_PATROL)

func _physics_process(delta: float) -> void:
	match current_state:
		State.ON_PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1:
					actor_velocity = actor.velocity_toward(path[1])
					actor.rotate_toward(path[1])
					actor.anim.play("run")
					actor.set_velocity(actor_velocity)
					actor.move_and_slide()
					actor.velocity
				else:
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
		State.ENGAGED:
				attack()
		State.ADVANCING:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1:
				actor_velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.anim.play("run")
				actor.set_velocity(actor_velocity)
				actor.move_and_slide()
				actor.velocity
			else:
				set_state(State.ON_PATROL)
			if target != null and weapon != null:
				set_state(State.ENGAGED)
		State.DEAD:
			var timer = Timer.new()
			self.add_child(timer)
			timer.connect("timeout",Callable(self,"queue_free"))
			timer.set_wait_time(1)
			timer.start()
			actor.team.set_team(Team.TeamName.DEAD)
			actor.set_z_index(-1)
			actor.collision.set_deferred("disabled", true)
			set_physics_process(false)
			print("ai is dead now", actor.ai)
		_:
			print("Error: found a state for our enemy that shouldnt exist")

func set_state(new_state: int):
	if new_state == current_state:
		return
	if new_state == State.ON_PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
	elif new_state == State.ADVANCING:
		actor.anim.play("run")
		if actor.has_reached_position(next_base):
			set_state(State.ON_PATROL)
	current_state = new_state
	emit_signal("state_changed", current_state)

func _on_PatrolTimer_timeout():
	var patrol_range = 50
	var random_x = randf_range(-patrol_range, patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false

func _on_DetectionZone_body_entered(body):
	target_list.append(body)
	if target and is_target_visible(body):
		# Цель уже есть, новую не нужно искать
		return

	if body.has_method("get_team") and body.get_team() != team and is_target_visible(body):
		target = body
		print(actor, " target in range ", target)
		set_state(State.ENGAGED)

func _on_DetectionZone_body_exited(body):
	if actor.health_stat.health == 0:
		return # Откровенная дрисня, пофиксить в дальнейшем. (Без этого не работает анимация).
	var target_to_del = 0
	for i in range(target_list.size()):
		if target_list[i] == body:
			target_to_del = i
			break
	target_list.remove_at(target_to_del)
	set_state(State.ADVANCING)
	in_sight = false


func handle_reload():
	if weapon.current_ammo == 0:
		weapon.start_reload()

func get_state():
	return current_state

func die():
	set_state(State.DEAD)

func is_target_visible(target) -> bool:
	# Значение в радианах, 2 ~= 120 градусов/2
	var field_of_view = 2
	var in_sight = false
	if abs(actor.position.angle_to(target.position)) <= field_of_view:
		var intersection = raycast(actor.position, target.position)
		if intersection.has("collider"):
			print("aboba is ", intersection.collider.name)
			if intersection.collider.name != "Buildings":
				in_sight = true
				return in_sight

	return in_sight

func attack():
	var intersection = raycast(actor.position, target.position)
	in_sight = false
	if intersection.has("collider"):
		print("aboba is ", intersection.collider.name)
		if intersection.collider.name != "Buildings":
			in_sight = true
	if not in_sight:
		target = null
	if target:
		actor.rotate_toward(target.position)
		weapon.shoot()
		handle_reload()
	else:
		set_state(State.ADVANCING)

func raycast(from, to):
	var params = PhysicsRayQueryParameters2D.new()
	params.from = global_transform.origin + Vector2.UP
	params.to = actor.global_transform.origin
	params.exclude = []
	var space_state = get_world_2d().direct_space_state
	var intersection = space_state.intersect_ray(params)
	return intersection
	
func defalut_strategy(entered_objects: Array):
	if len(entered_objects) == 0:
		return
	#var tif = target_in_fov()	
	var potential_target
	for entity in entered_objects:
		var intersection = raycast(actor.position, entity.position)
		if intersection.has("collider"):
			if intersection.collider.name != "Buildings":
				if entity == target: 
					in_sight = true 
					return
				potential_target = entity
	if potential_target == null:
		in_sight = false
		target = null
		set_state(State.ON_PATROL) 
	else:
		target = potential_target
		in_sight = true
	return
