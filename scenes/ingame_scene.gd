extends Node2D

@onready var fade_overlay := %FadeOverlay
@onready var pause_overlay := %PauseOverlay
@onready var game_over_overlay := %GameOverOverlay
@onready var hud_overlay := %HudOverlay
@onready var level := %room_generation

func _ready() -> void:
	fade_overlay.visible = true

	if SaveGame.has_save():
		SaveGame.load_game(get_tree())

	pause_overlay.game_exited.connect(_save_game)
	pause_overlay.resume.connect(_resume_game)
	level.gameover.connect(_game_over)
	game_over_overlay.try_again.connect(_try_again)

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		hud_overlay.visible = false
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true

func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _resume_game() -> void:
	get_tree().paused = false
	hud_overlay.visible = true

func _game_over() -> void:
	hud_overlay.visible = false
	get_viewport().set_input_as_handled()
	get_tree().paused = true
	game_over_overlay.grab_button_focus()
	game_over_overlay.visible = true

func _try_again() -> void:
	get_tree().reload_current_scene()


