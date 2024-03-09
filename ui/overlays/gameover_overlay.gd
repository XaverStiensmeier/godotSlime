extends CenterContainer


@onready var try_again_button := %TryAgainButton
@onready var exit_button := %ExitButton
@onready var menu_container := %MenuContainer


func _ready() -> void:
	try_again_button.pressed.connect(_try_again)
	exit_button.pressed.connect(_exit)


func grab_button_focus() -> void:
	try_again_button.grab_focus()


func _try_again() -> void:
	get_tree().paused = false
	visible = false
	SignalManager.try_again.emit()
	
	
func _exit() -> void:
	SignalManager.game_exited.emit()
	get_tree().quit()


func _pause_menu() -> void:
	menu_container.visible = true


func _unhandled_input(event):
	if event.is_action_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		if menu_container.visible:
			_try_again()

