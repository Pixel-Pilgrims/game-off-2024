extends Node2D

@onready var combat_manager = $CombatManager
@onready var hud = $UI/HUD

func _ready() -> void:
	# Set up HUD to fill screen
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	hud.offset_right = 0
	hud.offset_bottom = 0
	
	# Center the hand container
	var hand_container = $UI/HUD/HandContainer
	hand_container.custom_minimum_size.y = 300
	hand_container.anchor_left = 0.5
	hand_container.anchor_right = 0.5
	hand_container.anchor_top = 1.0
	hand_container.anchor_bottom = 1.0
	hand_container.offset_top = -300
	
	# Position end turn button
	var end_turn_container = $UI/HUD/EndTurnMarginContainer
	end_turn_container.anchor_left = 1.0
	end_turn_container.anchor_right = 1.0
	end_turn_container.anchor_top = 1.0
	end_turn_container.anchor_bottom = 1.0
	
	# Position energy display
	var energy_container = $UI/HUD/EnergyMarginContainer
	energy_container.anchor_left = 1.0
	energy_container.anchor_right = 1.0
	
	$UI/HUD/EndTurnMarginContainer/EndTurnButton.pressed.connect(_on_end_turn_pressed)
	
	# Connect to enemy death or victory condition
	$EnemiesContainer.child_exiting_tree.connect(_check_combat_state)

func _check_combat_state(_node) -> void:
	# If all enemies are dead
	if $EnemiesContainer.get_child_count() <= 1:  # <= 1 because the signal fires before the node is fully removed
		_on_combat_won()

func _on_combat_won() -> void:
	AdventureSystem.complete_current_encounter()
	queue_free()

func _on_end_turn_pressed() -> void:
	combat_manager.end_turn()
