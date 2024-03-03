extends Node2D

signal gameover
signal health_changed(health: float)

@export var enemy: PackedScene


@onready var doors: Marker2D = %doors


var basic_enemy_count: int = 3
var all_enemies: Array
var cleared: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_level()


func start_level() -> void:
	## enemy spawning
	basic_enemy_count = randi_range(2,5)
	for e in basic_enemy_count:
		var new_enemy = enemy.instantiate()
		call_deferred("add_child", new_enemy)
		new_enemy.global_position = Vector2(randi_range(50,526),randi_range(50,274))
		all_enemies.append(new_enemy)


func _process(delta) -> void:
	room_cleared()


func room_cleared() -> void:
	if all_enemies.size() == 0 and not cleared:
		cleared = true
		doors.show()


func delete_me(e) -> void:
	all_enemies.erase(e)


func _on_door_right_body_entered(body) -> void:
	if cleared:
		start_level()
		doors.hide()
		cleared = false


func _on_door_left_body_entered(body) -> void:
	if cleared:
		start_level()
		doors.hide()
		cleared = false

func on_player_health_changed(health: float) -> void:
	health_changed.emit(health)


func game_over() -> void:
	gameover.emit()
