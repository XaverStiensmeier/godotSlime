extends ProgressBar

@onready var damage_bar: ProgressBar = %DamageBar
@onready var timer: Timer = %Timer

var previous_health := 0.0

func _ready() -> void:
	SignalManager.health_changed.connect(_update_health_bar)


func _update_health_bar(health) -> void:
	value = health
	if health < previous_health: # player took damage
		timer.start()
	else: # player healed
		damage_bar.value = health
	
	previous_health = health
	
	pass


func _on_timer_timeout() -> void:
	damage_bar.value = previous_health
