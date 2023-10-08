extends Node2D
class_name Team


enum TeamName{
	PLAYER,
	ENEMY,
	NEUTRAL,
	DEAD
}

@export var team: TeamName = TeamName.NEUTRAL :
	get:
		return team # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_team

func set_team(new_team):
	team = new_team
