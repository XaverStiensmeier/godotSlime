extends Node2D

@export var level:PackedScene

@onready var map = %map
@onready var levels = %levels

@export var space_ship_length := 7
@export var space_ship_room_size := 20
@export var space_ship_room_branch_min_size := 2
@export var space_ship_room_branch_max_size := 4
var space_ship_room_all_postions:Array
var space_ship_vertical_room_branches:Array
var space_ship_horizontal_room_branches:Array


var player_position:Vector2 = Vector2.ZERO
var current_level:Node2D
var completed_levels:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_branch:Array
	## this is the first and main room branch. last room will always have a boos/command pod
	for main_branch in space_ship_length:
		space_ship_room_all_postions.append(Vector2(main_branch,0))
		new_branch.append(Vector2(main_branch,0))
		space_ship_room_size -=1
	space_ship_horizontal_room_branches.append(new_branch)
	
	## vertical and horizontal branches one can only spawn on the other
	var is_vertical:bool = true
	while space_ship_room_size > 0:
		if is_vertical:
			is_vertical = false
			generate_vertical_branches(randi_range(space_ship_room_branch_min_size,min(space_ship_room_branch_max_size,space_ship_room_size)))
		else:
			is_vertical = true
			generate_horizontal_branches(randi_range(space_ship_room_branch_min_size,min(space_ship_room_branch_max_size,space_ship_room_size)))

	for b in space_ship_room_all_postions:
		if b == Vector2(space_ship_length-1,0):
			map.add_map_tile(b,true)
		else:
			map.add_map_tile(b)
	generate_level()
	
	
func generate_level() -> void:
## removes level from scene. it is already saved
	if current_level != null:
		levels.call_deferred("remove_child",current_level)

## if level is already completed, pull it from completed_levels
	if completed_levels.has(player_position):
		levels.call_deferred("add_child",completed_levels[player_position])
		current_level = completed_levels[player_position]
		map.show_player_on_map(space_ship_room_all_postions, player_position)

## new level is instantiated here
	elif !completed_levels.has(player_position):
		var new_level
		new_level = level.instantiate()
		levels.call_deferred("add_child",new_level)
		var doors:Array
		var doors_available:Array = [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN] ## rooms are saved on vector grid array, this will check if room has neighbor rooms
		for door in doors_available.size():
			if space_ship_room_all_postions.has(player_position+doors_available[door]):
				doors.append(door)
		new_level.call_deferred("open_doors",doors, self) ## shows correct doors when finihing level, also starts level 
		map.show_player_on_map(space_ship_room_all_postions, player_position) ## new position on map
		
		## not yet completed, it's set in advanced
		completed_levels[player_position] = new_level
		
		current_level = completed_levels[player_position]

func new_player_position(new_pos:Vector2) -> void:
	player_position += new_pos ## it tells which level should be generated or shown next
	generate_level()


func generate_vertical_branches(length:int) -> void:
## decides on what horizontal room this vertical branch will spawn
	var random_branch:int = randi_range(0,space_ship_horizontal_room_branches.size()-1)
	var start_branch_postion:Vector2 = \
	space_ship_horizontal_room_branches[random_branch][randi_range(0,space_ship_horizontal_room_branches[random_branch].size()-1)] # random room in random horizontal branch
	start_branch_postion += Vector2.UP
	var new_branch:Array

## always check if there is one free space between branches so its not all cramped up
	var error_proof:int ## after 30 loops go back
	while !check_for_neighbours(true, start_branch_postion):
		random_branch = randi_range(0,space_ship_horizontal_room_branches.size()-1)
		start_branch_postion = \
		space_ship_horizontal_room_branches[random_branch][randi_range(0,space_ship_horizontal_room_branches[random_branch].size()-1)]
		start_branch_postion += Vector2.UP
		error_proof+=1
		if error_proof > 30:
			push_error("no place for horizontal, make some changes in branch sizes")
			return 

## how long the branch will be
	for branch in length:
		if !space_ship_room_all_postions.has(start_branch_postion): ## no duplicates
			new_branch.append(start_branch_postion)
			space_ship_room_size -=1
		start_branch_postion += Vector2.UP

## ofsets the branch 
	var branch_repositin:int = randi_range(0, new_branch.size())
	for repo in branch_repositin:
		if check_for_neighbours(true, new_branch[0] + (Vector2.DOWN*2)+Vector2.DOWN*repo):
			new_branch[new_branch.size()-(1+repo)] = Vector2(new_branch[0] + (Vector2.DOWN*2)+Vector2.DOWN*repo)
		else:
			break

## add new vertical branch to array
	space_ship_vertical_room_branches.append(new_branch)
## IMPORTANT rooms need to be added on the last step
	for b in new_branch:
		space_ship_room_all_postions.append(b)


## same as vertical just oposite
func generate_horizontal_branches(length:int) -> void:
	var random_branch:int = randi_range(0,space_ship_vertical_room_branches.size()-1)
	var start_branch_postion:Vector2 = \
	space_ship_vertical_room_branches[random_branch][randi_range(0,space_ship_vertical_room_branches[random_branch].size()-1)]
	start_branch_postion += Vector2.LEFT
	var new_branch:Array
	
	var error_proof:int ## after 30 loops go back
	while !check_for_neighbours(false, start_branch_postion):
		random_branch = randi_range(0,space_ship_vertical_room_branches.size()-1)
		start_branch_postion = \
		space_ship_vertical_room_branches[random_branch][randi_range(0,space_ship_vertical_room_branches[random_branch].size()-1)]
		start_branch_postion += Vector2.LEFT
		error_proof +=1
		if error_proof > 30:
			push_error("no place for horizontal, make some changes in branch sizes")
			return 

	for branch in length:
		if !space_ship_room_all_postions.has(start_branch_postion): ## no duplicates
			new_branch.append(start_branch_postion)
			space_ship_room_size -=1
		start_branch_postion += Vector2.LEFT
	
	var branch_repositin:int = randi_range(0, new_branch.size())
	for repo in branch_repositin:
		if check_for_neighbours(false, new_branch[0] + (Vector2.RIGHT*2)+Vector2.RIGHT*repo):
			new_branch[new_branch.size()-(1+repo)] = Vector2(new_branch[0] + (Vector2.RIGHT*2)+Vector2.RIGHT*repo)
		else:
			break
	space_ship_horizontal_room_branches.append(new_branch)

	for b in new_branch:
		space_ship_room_all_postions.append(b)

## always check if there is one free space between branches so its not all cramped up
func check_for_neighbours(vertical:bool, tile_pos:Vector2) -> bool:
	if vertical:
		if space_ship_room_all_postions.has(tile_pos+Vector2.LEFT):
			return false
		if space_ship_room_all_postions.has(tile_pos+Vector2.RIGHT):
			return false
		if space_ship_room_all_postions.has(tile_pos):
			return false
		return true
	if !vertical:
		if space_ship_room_all_postions.has(tile_pos+Vector2.UP):
			return false
		if space_ship_room_all_postions.has(tile_pos+Vector2.DOWN):
			return false
		if space_ship_room_all_postions.has(tile_pos):
			return false
		return true
	return true




