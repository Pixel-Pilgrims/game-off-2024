extends Control



func _ready() -> void:
	BackgroundSystem.setup_background(load("res://assets/backgrounds/study.png"))

func _on_adventure_button_pressed() -> void:
	pass # Go to run tree

func _on_decoder_button_pressed() -> void:
	pass # Go to decoder

func _on_stone_button_pressed() -> void:
	pass # Go to stone powers and progress

func _on_loadout_button_pressed() -> void:
	pass # Go to deck viewer and loadout
