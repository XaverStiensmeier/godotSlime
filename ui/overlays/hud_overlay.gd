extends MarginContainer

@export var level: Node2D


@onready var health_label:= %HealthLabel

func _ready() -> void:
	level.health_changed.connect(_update_health_label)


func _update_health_label(health) -> void:
	printt("updating health label")
	health_label.text = "Health: " + str(health)
