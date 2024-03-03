extends CharacterBody2D

#test123

var SPEED:int = 300
var health:int = 100


@onready var player_sprite: Sprite2D = %player_sprite


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("move_left", "move_right","move_up", "move_down")
	if direction.length() != 0:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	

func eat(value: int) -> void:
	player_sprite.frame += value 
	
	


func _on_eat_detection_body_entered(body: Node2D) -> void:
	body.eat(self)
