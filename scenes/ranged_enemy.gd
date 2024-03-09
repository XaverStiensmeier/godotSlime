extends enemy

signal laser_shot(laser)

@export var shoot_distance := 300

var shoot_direction:Vector2 ## Normalized moving direction
var laser_scene := preload("res://scenes/laser.tscn")

func _ready():
	attack_distance = shoot_distance


func try_to_eat() -> float:
	# If enemy is currently not chasing or in attack state, the player can eat the enemy (enemy is removed from the game)
	# and we return the eat_value of the enemy to the player
	if true: # TODO find a better way and remove true
		queue_free()
		get_parent().delete_me(self)
		return eat_value
	# else we return 0 and the enemy remains in the game
	return 0.0


func attack() -> void:
	# Calculate shoot direction towards player
	print("Attacking!")
	var shoot_direction = global_position.direction_to(player.global_position).normalized()
	var l = laser_scene.instantiate()
	l.global_position = global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)
	attack_timer.start(2)


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player == null:
		current_state = STATES.chase
		player = body


func _on_attack_timer_timeout() -> void:
	## some more attack shananigans
	print("Why")
	if attack_ready: ## shows where attack will be placed
		attack_ready = false
		attack_timer.start(attack_timeout) ## actual attack slash duration
	elif not attack_ready: ## placed attack
		current_state = STATES.circle
		print("Changing state")


func _on_attack_recharge_timeout() -> void:
	attack_ready = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player != null:
		player.health -= damage_per_attack
