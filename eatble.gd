extends Node

func eat(player, value, enemie):
	player.eat(value)
	enemie.queue_free()
