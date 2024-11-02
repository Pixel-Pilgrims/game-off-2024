extends Node2D

@onready var combat_manager = $CombatManager

func _ready() -> void:
	$UI/HUD/EndTurnButton.pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed() -> void:
	combat_manager.end_turn()
