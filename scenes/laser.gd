extends Area2D

@export var speed := 500

var movement_vector := Vector2(0, -1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
