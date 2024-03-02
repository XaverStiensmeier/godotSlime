extends CharacterBody2D

@onready var eatable = preload("res://eatble.gd").new()
@onready var atk_time = $Marker2D/Attack_time
var player

const SPEED = 100.0
var direction:Vector2 ## Normalized moving direction
var new_direction:Vector2 ## For smoother direction changing
var attack_ready:bool = true

var current_state = STATES.idle
enum STATES {
	idle,
	chase,
	circle,
	run,
	attack
}

func _physics_process(delta):
	state_machine()

func state_machine():
	match current_state:
		STATES.idle:
			new_direction = Vector2.ZERO
		
		STATES.chase:
			new_direction = global_position.direction_to(player.global_position)
			if global_position.distance_to(player.global_position) < 40: ## how close to the player for attack
				current_state = STATES.attack
		
		STATES.run:
			new_direction = player.global_position.direction_to(global_position)
			if attack_ready:
				current_state = STATES.chase
		
		STATES.circle:
			if global_position.distance_to(player.global_position) < 80:
				new_direction = player.global_position.direction_to(global_position)
			elif global_position.distance_to(player.global_position) > 120:
				new_direction = global_position.direction_to(player.global_position)

			else:
				direction = (player.global_position.direction_to(global_position)).orthogonal()
			
			if attack_ready:
				current_state = STATES.chase
				


		STATES.attack:
			new_direction = Vector2.ZERO
			if atk_time.is_stopped(): ## Can call if there is no attack in action
				attack()

	direction = direction.lerp(new_direction,0.1)
	velocity = direction * SPEED
	move_and_slide()
 
func eat(player):
	if current_state not in [STATES.chase, STATES.attack]:
		eatable.eat(player,1,self) ## Function that all eatables will be able to call
		
		## TESTIN PERPUSES tells the room manager i dont exist anymore
		get_parent().delete_me(self)

func attack():
	## attack indicator shananigans
	$Marker2D/Aim.rotation = global_position.direction_to(player.global_position).angle()
	$Marker2D/Attack.rotation = $Marker2D/Aim.rotation
	$Marker2D/Aim.show()
	atk_time.start(.5) ## for how long attack indicator is shown before attack



func _on_player_detection_body_entered(body):
	if body.is_in_group("player") and player == null:
		current_state = STATES.chase
		player = body


#func _on_player_detection_body_exited(body):
	#if body == player:
		#current_state = STATES.idle
		#player = null

func _on_attack_time_timeout():
	## some more attack shananigans
	if attack_ready: ## shows where attack will be placed
		attack_ready = false
		$Marker2D/Attack.show()
		atk_time.start(.1) ## actual attack slash duration
	elif not attack_ready: ## placed attack
		current_state = STATES.circle
		$Marker2D/Attack.hide()
		$Marker2D/Aim.hide()
		$Marker2D/Attack_recharge.start(4) ## cool down till next attack


func _on_attack_recharge_timeout():
	attack_ready = true
