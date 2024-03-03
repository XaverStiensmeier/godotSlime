extends CharacterBody2D
## This is the script for the player character (slime).
##
## It controls the player's health (keeping track of the value, but also triggering the update of the health label)
## 
## When health drops to 0, the game over event is triggered.
##
## This script also handles player movement (including speed, acceleration and friction).
##
## 
## 
## TODO: implement dash

@export var max_health := 100.0
@export var starting_health := 25.0
@export var speed := 200.0
@export var acceleration := 1000.0
@export var friction := 3000.0

@onready var player_sprite: Sprite2D = %Sprite2D

## The players health, including a setter which triggers different events and updates the health label
var health : float :
	set(value):
		if value != health:	 # if value is different from current health
			if value < health: # if value is less than current health, player takes damage
				pass
				#TODO: Take damage animation. Create a take damage sprite animation
				#damage_animation_player.stop(false)
				#damage_animation_player.play("TakeDamage")
			health = clamp(value, 0, max_health)
			
			# Update health label
			get_parent().health_changed.emit(health)
			
			# Update sprite frame
			update_player_sprite()
			
			printt("Player health:", str(health) + "/" + str(max_health))  # TODO remove
			
			if health <= 0:
				get_parent().game_over()


func _ready() -> void:
	health = starting_health


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the acceleration/friction
	var input: Vector2 = Input.get_vector("move_left", "move_right","move_up", "move_down")
	handle_acceleration(input, delta)

	move_and_slide()

## Handles the player's acceleration and friction
func handle_acceleration(input, delta) -> void:
	if input:
		velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

## Currently in place to change the player's sprite frame according to the current health. #TODO Change to scaling instead of changing frame??
func update_player_sprite() -> void:
	
	# Calculate the health percentage
	# TODO: remove the hard coded 25.0, it is there so at 25% health you instead get the sprite frame 0, instead of frame 1 and so on
	# This code will change when we have a sprite animation which just scales. Working with the scale is a better approach imo.
	var health_percentage = (health - 25.0) / max_health
	
	# Calculate the frame index
	var frameIndex : int = int(health_percentage * player_sprite.hframes)
	
	# Ensure the frame index is within bounds
	frameIndex = clamp(frameIndex, 0, player_sprite.hframes - 1)
	
	player_sprite.frame = frameIndex


func _on_eat_detection_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("try_to_eat"):
		health += body.try_to_eat()
	# TODO: Consume powerups / consumables 
	#if body.has_method("try_to_consume"):

