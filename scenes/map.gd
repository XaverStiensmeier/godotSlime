extends Marker2D

@export var map_tile:PackedScene
@export var boss_map_tile:PackedScene

var map_tiles:Array
var player_position:Vector2

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("map"):
		if visible:
			hide()
		else:
			show()

## genetaring map tiles 
func add_map_tile(pos:Vector2, boss:bool = false) -> void:
	if !boss:
		var new_map_tile = map_tile.instantiate()
		add_child(new_map_tile)
		new_map_tile.position = pos * 13
		map_tiles.append(new_map_tile)
	elif boss:
		var new_map_tile = boss_map_tile.instantiate()
		add_child(new_map_tile)
		new_map_tile.position = pos * 13
		map_tiles.append(new_map_tile)

## colors polygon map tile, currently on is red, discovered is gray
func show_player_on_map(rooms:Array, player_pos:Vector2) -> void:
	map_tiles[rooms.find(player_position)].color = Color.DIM_GRAY
	player_position = player_pos
	map_tiles[rooms.find(player_position)].color = Color.RED
