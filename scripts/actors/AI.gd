extends Node2D
class_name AI

signal state_changed(new_state)


enum State {
	PATROL, 
	ENGAGE,
	ADVANCE,
	DEAD,
}


onready var patrol_timer = $PatrolTimer
export var vision_core_arc = 60.0


var current_state: int = -1 setget set_state, get_state
var target: KinematicBody2D = null
var weapon: Weapon = null
var actor: Actor = null
var actor_velocity: Vector2 = Vector2.ZERO
var team: int = -1 
var pathfinding: Pathfinding



var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false

var next_base: Vector2 = Vector2.ZERO

var angle_cone_of_vision = deg2rad(30.0)
var max_view_distance = 800.0
var angle_between_rays = deg2rad(5.0) 

func initialize(actor: KinematicBody2D, weapon: Weapon, team: int):
	self.actor = actor
	self.weapon = weapon
	self.team = team
	weapon.connect("weapon_out_of_ammo", self, "handle_reload")
	actor.connect("handle_shot", self, "die")

func _ready():
	set_state(State.PATROL)
	
func aim():
	if target != null and weapon != null and target.get_team() != team:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, target.position, [self])
		if result.collider.has_method("get_team") and result.collider.team != actor.team:
			actor.rotate_toward(target.position)
			if abs(actor.global_position.angle_to(target.position)) <= 0.25:
					weapon.shoot()
					if weapon.current_ammo == 0: 
						handle_reload()
		else:
			set_state(State.ADVANCE)
#	var target_extents = target.get_node("CollisionShape2D").shape.extents - Vector2(5, 5)
#	var nw= target.position - target_extents
#	var se= target.position + target_extents
#	var ne= target.position + Vector2(target_extents.x, -target_extents.y)
#	var sw= target.position + Vector2(-target_extents.x, +target_extents.y)
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1:
					actor_velocity = actor.velocity_toward(path[1])
					actor.rotate_toward(path[1])
					actor.anim.play("run")
					actor.move_and_slide(actor_velocity)
				else:
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
		State.ENGAGE:
				aim()
		State.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1:
				actor_velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.anim.play("run")
				actor.move_and_slide(actor_velocity)
			else:
				set_state(State.PATROL)
			if target != null and weapon != null:
				set_state(State.ENGAGE)
		State.DEAD:
			print("I am dead")
			return
		_:
			print("Error: found a state for our enemy that shouldnt exist")

			
func set_state(new_state: int):
	if new_state == current_state:
		return 
	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
	elif new_state == State.ADVANCE:
		actor.anim.play("run")
		if actor.has_reached_position(next_base):
			set_state(State.PATROL)
	current_state = new_state
	emit_signal("state_changed", current_state)



func _on_PatrolTimer_timeout():
	var patrol_range = 50
	var random_x = rand_range(-patrol_range, patrol_range)
	var random_y = rand_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false



func _on_DetectionZone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body


func _on_DetectionZone_body_exited(body):
	if target and body == target:
		target = null
		set_state(State.ADVANCE)


func handle_reload():
	if weapon.current_ammo == 0:
		weapon.start_reload()

func get_state():
	return current_state
	
func die():
	set_state(State.DEAD)
	actor.collision.set_deferred("disabled", true)
	actor.team.set_team(Team.TeamName.DEAD)
	actor.set_z_index(-1)
	set_physics_process(false)
