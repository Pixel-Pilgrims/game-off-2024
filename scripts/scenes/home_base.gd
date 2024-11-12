# scripts/scenes/home_base.gd
extends Control

func _ready() -> void:
	BackgroundSystem.setup_background(load("res://assets/backgrounds/study.png"))

func _on_adventure_button_pressed() -> void:
	var adventure: AdventureMapData = AdventureGenerator.generate_adventure()
	
	# Get reference to Main scene
	var main = get_node("/root/Main")
	
	# Create new adventure map scene
	var adventure_map = preload("res://scenes/adventure_map.tscn").instantiate()
	
	# Use Main's transition method
	main.transition_to_scene(adventure_map)
	
	# Start the adventure after transition
	AdventureSystem.start_adventure(adventure)

func _on_decoder_button_pressed() -> void:
	pass # Go to decoder

func _on_stone_button_pressed() -> void:
	pass # Go to stone powers and progress

func _on_loadout_button_pressed() -> void:
	pass # Go to deck viewer and loadout
