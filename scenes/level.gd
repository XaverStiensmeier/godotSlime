extends Node2D

@export var enemy: PackedScene
@export var player: PackedScene

@onready var doors: Marker2D = %doors

var active_player:CharacterBody2D
var room_manager
var basic_enemy_count: int = 3
var all_enemies: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_level()


func start_level() -> void:
	## enemy spawning
	basic_enemy_count = randi_range(1,1)
	for e in basic_enemy_count:
		var new_enemy = enemy.instantiate()
		call_deferred("add_child", new_enemy)
		new_enemy.global_position = Vector2(randi_range(50,526),randi_range(50,274))
		all_enemies.append(new_enemy)
	## player spawn
	set_player()

func _process(delta) -> void:
	room_cleared()


var time_in_room:float = 0 ## time after doors show if room is empty to avoid bugs, resets in door_used
func room_cleared() -> void:
	time_in_room += get_process_delta_time()
	if all_enemies.size() == 0 and time_in_room > .2:
		doors.show()


func delete_me(e) -> void:
	all_enemies.erase(e)

## sets player, if it already exists reset position
func set_player():
	if active_player == null:
		active_player = player.instantiate()
		add_child(active_player)
		active_player.global_position = Vector2(290,157)
	else:
		active_player.global_position = Vector2(290,157)

func open_doors(doors_to_open:Array, manager:Node2D) -> void: ## 0 = left, 1 = right, 2 = up, 3 = down 
	for door in doors.get_child_count():
		if doors_to_open.has(door):
			doors.get_child(door).show()
	room_manager = manager



func door_used(next_room:Vector2) -> void:
	set_player()
	doors.hide()
	time_in_room = 0
	room_manager.new_player_position(next_room)

func _on_door_right_body_entered(body) -> void:
	if %door_right.visible and body.is_in_group("player") and doors.visible:
		door_used(Vector2.RIGHT)



func _on_door_left_body_entered(body) -> void:
	if %door_left.visible and body.is_in_group("player") and doors.visible:
		door_used(Vector2.LEFT)



func _on_door_up_body_entered(body: Node2D) -> void:
	if %door_up.visible and body.is_in_group("player") and doors.visible:
		door_used(Vector2.UP)


func _on_door_down_body_entered(body: Node2D) -> void:
	if %door_down.visible and body.is_in_group("player") and doors.visible:
		door_used(Vector2.DOWN)
