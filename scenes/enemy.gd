extends CharacterBody2D

@export var speed := 100.0
@export var attack_timeout := 0.1
@export var attack_recharge := 2
@export var attack_indicator_timer := 0.5
@export var attack_distance := 40
@export var circle_min_distance := 100
@export var circle_max_distance := 140
@export var change_rotation_timer := 2 ## after change_rotation_timer in seconds, rotation is changed when circling
@export var damage_per_attack := 25.0
@export var eat_value := 25.0

@onready var attack_timer: Timer = %Attack_timer
@onready var attack_polygon: Polygon2D = %Attack_polygon
@onready var aim_polygon: Polygon2D = %Aim_polygon
@onready var attack_recharge_timer: Timer = %Attack_recharge_timer
@onready var nav_agent := %NavigationAgent2D as NavigationAgent2D

var player: Node2D
var direction:Vector2 ## Normalized moving direction
var new_direction:Vector2 ## For smoother direction changing
var attack_ready := true
var current_state = STATES.idle
var rng := RandomNumberGenerator.new()
var change_rotation := 0.0
var rotate_direction := 1
var change_location := 1

enum STATES {
	idle,
	chase,
	circle,
	run,
	attack
}

func _physics_process(delta: float) -> void:
	state_machine(delta)


func state_machine(delta) -> void:
	new_direction = to_local(nav_agent.get_next_path_position()).normalized()
	match current_state:
		STATES.idle:
			pass
		STATES.chase:
			if global_position.distance_to(player.global_position) < attack_distance: ## how close to the player for attack
				current_state = STATES.attack
		STATES.circle:
			if attack_ready:
				current_state = STATES.chase

		STATES.attack:
			if attack_timer.is_stopped(): ## Can call if there is no attack in action
				attack()

	direction = direction.lerp(new_direction,0.1)
	velocity = direction * speed
	move_and_slide()


func makepath() -> void:
	print(global_position)
	match current_state:
		STATES.idle or STATES.attack:
			nav_agent.target_position = Vector2.ZERO
		STATES.chase:
			if player != null:
				nav_agent.target_position = player.global_position
		STATES.circle:
			print(global_position.distance_to(player.global_position) < circle_min_distance)
			nav_agent.target_position = Vector2(100,100)
			if global_position.distance_to(player.global_position) < circle_min_distance:
				nav_agent.target_position = global_position + player.global_position.direction_to(global_position)*100
			elif global_position.distance_to(player.global_position) > circle_max_distance:
				nav_agent.target_position = global_position + global_position.direction_to(player.global_position)*100
			else:
				nav_agent.target_position = global_position + player.global_position.direction_to(global_position).orthogonal()*rotate_direction*10


func try_to_eat() -> float:
	# If enemy is currently not chasing or in attack state, the player can eat the enemy (enemy is removed from the game)
	# and we return the eat_value of the enemy to the player
	if current_state not in [STATES.chase, STATES.attack]:
		queue_free()
		## TESTIN PERPUSES tells the room manager i dont exist anymore
		get_parent().delete_me(self)
		return eat_value
	# else we return 0 and the enemy remains in the game
	return 0.0


func attack() -> void:
	## attack indicator shananigans
	aim_polygon.rotation = global_position.direction_to(player.global_position).angle()
	attack_polygon.rotation = aim_polygon.rotation
	aim_polygon.show()
	attack_timer.start(attack_indicator_timer) ## for how long attack indicator is shown before attack


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player == null:
		current_state = STATES.chase
		player = body


func _on_attack_timer_timeout() -> void:
	## some more attack shananigans
	if attack_ready: ## shows where attack will be placed
		attack_ready = false
		attack_polygon.show()
		attack_timer.start(attack_timeout) ## actual attack slash duration
	elif not attack_ready: ## placed attack
		current_state = STATES.circle
		attack_polygon.hide()
		aim_polygon.hide()
		attack_recharge_timer.start(attack_recharge) ## cool down till next attack


func _on_attack_recharge_timeout() -> void:
	attack_ready = true


func _on_timer_timeout():
	makepath()
