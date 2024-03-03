extends CharacterBody2D

var SPEED:int = 300
var health:int = 100

@onready var sprite:Sprite2D = $Slime_sprite

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("ui_left", "ui_right","ui_up", "ui_down")
	if direction.length() != 0:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	


func eat(value):
	sprite.frame += value 
	
func _on_eat_detection_area_entered(area):
	area.eat(self)


func _on_eat_detection_body_entered(body):
	body.eat(self)
