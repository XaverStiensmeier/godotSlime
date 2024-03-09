extends CharacterBody2D

@export var speed := 50.0
@export var bullet_speed := 75.0
@export var eat_value := 25.0
@export var shoot_distance := 300
@export var damage_per_attack := 15

@onready var bullet_timer: Timer = %Bullet_timer
@onready var bullet: CharacterBody2D = %Bullet

var player: Node2D
var direction:Vector2 ## Normalized moving direction
var new_direction:Vector2
var shoot_direction:Vector2 ## Normalized moving direction
var attack_ready := true
var current_state = STATES.idle
var change_rotation := 0.0
var rotate_direction := 1
var change_location := 1

enum STATES {
	idle,
	wandering,
	shoot
}

func _physics_process(delta) -> void:
	state_machine(delta)

func state_machine(delta) -> void:
	match current_state:
		STATES.idle:
			new_direction = Vector2.ZERO

		STATES.wandering:
			new_direction = player.global_position.direction_to(global_position)
			if attack_ready:
				current_state = STATES.shoot

		STATES.shoot:
			new_direction = Vector2.ZERO
			if global_position.distance_to(player.global_position) < shoot_distance and bullet_timer.is_stopped(): ## how close to the player for attack
				shoot()

	direction = direction.lerp(new_direction,0.1)
	velocity = direction * speed
	move_and_slide()

func try_to_eat() -> float:
	# If enemy is currently not chasing or in attack state, the player can eat the enemy (enemy is removed from the game)
	# and we return the eat_value of the enemy to the player
	if current_state not in [STATES.shoot]:
		queue_free()
		get_parent().delete_me(self)
		return eat_value
	# else we return 0 and the enemy remains in the game
	return 0.0


func shoot() -> void:
	# Calculate shoot direction towards player
	var shoot_direction = global_position.direction_to(player.global_position).normalized()
	var shoot_velocity = shoot_direction * bullet_speed

	bullet.rotation = bullet.global_position.direction_to(player.global_position).angle()
	bullet.velocity = shoot_velocity

	bullet.show()
	bullet.move_and_slide()
	current_state = STATES.wandering
	bullet_timer.start(3)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player == null:
		current_state = STATES.shoot
		player = body

func _on_attack_timer_timeout() -> void:
	bullet.hide()
	current_state = STATES.shoot
	bullet.global_position = global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player != null:
		bullet.hide()
		player.health -= damage_per_attack
