extends Node2D
class_name Team 


enum TeamName{
	PLAYER,
	ENEMY,
	NEUTRAL
}

export (TeamName) var team = TeamName.NEUTRAL


