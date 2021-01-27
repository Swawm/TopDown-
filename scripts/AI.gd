extends Node2D
class_name AI

signal state_changed(new_state)

enum State {
	PATROL, 
	ENGAGE,
	ADVANCE
}


onready var patrol_timer = $PatrolTimer

var current_state: int = -1 setget set_state, get_state
var target: KinematicBody2D = null
var weapon: Weapon = null
var actor: Actor = null
var actor_velocity: Vector2 = Vector2.ZERO
var team: int = -1 


var origin: Vector2 = Vector2.ZERO
var patrol_locaition: Vector2 = Vector2.ZERO
var patrol_locaition_reached: bool = false


var next_base: Vector2 = Vector2.ZERO


func _ready():
	set_state(State.PATROL)
	print(get_state())
	
	
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			if not patrol_locaition_reached:
				actor_velocity = actor.velocity_toward(patrol_locaition)
				actor.move_and_slide(actor_velocity)
				actor.rotate_toward(patrol_locaition)
				if actor.has_reached_position(patrol_locaition):
					patrol_locaition_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
		State.ENGAGE:
			if target != null and weapon != null:
				actor.rotate_toward(target.global_position)
				var angle_to_player = actor.global_position.direction_to(target.global_position).angle()
				if abs(actor.rotation - angle_to_player) < 0.1:
					weapon.shoot()
					if weapon.current_ammo == 0:
						handle_reload()
			else:
				print("Error: no weapon or player exist")
		State.ADVANCE:
			if actor.has_reached_position(next_base):
				set_state(State.PATROL)
			else:
				actor_velocity = actor.velocity_toward(next_base)
				actor.move_and_slide(actor_velocity)
				actor.rotate_toward(next_base)
		_:
			print("Error: found a state for our enemy that shouldnt exist")
	pass
	
func set_state(new_state: int):
	if new_state == current_state:
		return 
	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_locaition_reached = true
		
	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_base):
			set_state(State.PATROL)
			
	current_state = new_state
	emit_signal("state_changed", current_state)

func initialize(actor: KinematicBody2D, weapon: Weapon, team: int):
	self.actor = actor
	self.weapon = weapon
	self.team = team
	weapon.connect("weapon_out_of_ammo", self, "handle_reload")


func _on_PatrolTimer_timeout():
	var patrol_range = 50
	var random_x = rand_range(-patrol_range, patrol_range)
	var random_y = rand_range(-patrol_range, patrol_range)
	patrol_locaition = Vector2(random_x, random_y) + origin
	patrol_locaition_reached = false



func _on_DetectionZone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body



func _on_DetectionZone_body_exited(body):
	if target and body == target:
		set_state(State.ADVANCE)
		target = null

func handle_reload():
	if weapon.current_ammo == 0:
		weapon.start_reload()

func get_state():
	return current_state
