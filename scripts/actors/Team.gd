extends Node2D
class_name Team


enum TeamName{
	PLAYER,
	ENEMY,
	NEUTRAL,
	DEAD
}

export (TeamName) var team = TeamName.NEUTRAL setget set_team

func set_team(new_team):
	team = new_team
