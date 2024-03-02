extends Node2D

var basic_enemy_count = 3
var all_enemies:Array
var cleared:bool = false

@onready var basic_enemy = preload("res://basic_enemy.tscn")

@onready var doors = $doors


# Called when the node enters the scene tree for the first time.
func _ready():
	start_level()


func start_level():
	## enemy spawning
	basic_enemy_count = randi_range(2,5)
	for e in basic_enemy_count:
		var new_enemy = basic_enemy.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = Vector2(randi_range(100,900),randi_range(50,400))
		all_enemies.append(new_enemy)

func _process(delta):
	room_cleared()

func room_cleared():
	if all_enemies.size() == 0 and not cleared:
		cleared = true
		doors.show()

func delete_me(e):
	all_enemies.erase(e)


func _on_door_right_body_entered(body):
	if cleared:
		start_level()
		doors.hide()
		cleared = false


func _on_door_left_body_entered(body):
	if cleared:
		start_level()
		doors.hide()
		cleared = false
