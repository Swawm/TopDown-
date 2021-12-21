extends Node

func play_random_death_sound():
	var children = get_node(".").get_children()
	children.shuffle()
	var rand_child = children[0]
	rand_child.play()

