extends Node2D

signal state_changed(new_state)

enum State {
	PATROL, 
	ENGAGE
}

onready var player_detection_zone = $PlayerDetectionZone

var current_state: int = State.PATROL setget set_state
var player: Player = null
var weapon: Weapon = null
var actor = null

func _process(delta):
	match current_state:
		State.PATROL:
			pass
		State.ENGAGE:
			if player != null and weapon != null:
				actor.rotation = actor.global_position.direction_to(player.global_position).angle()
				weapon.shoot()
			else:
				print("Error: no weapon or player exist")
		_:
			print("Error: found a state for our enemy that shouldnt exist")
	pass
	
func set_state(new_state: int):
	if new_state == current_state:
		return 
	current_state = new_state
	emit_signal("state_changed", current_state)
	

func initialize(actor, weapon: Weapon):
	self.actor = actor
	self.weapon = weapon

func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		set_state(State.ENGAGE)
		player = body


func _on_PlayerDetectionZone_body_exited(body):
	if body.is_in_group("Player"):
		set_state(State.PATROL)
		player = body
	pass # Replace with function body.
