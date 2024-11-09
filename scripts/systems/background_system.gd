extends Node

# Preload the background textures
const MAIN_MENU_BG = preload("res://assets/backgrounds/main_menu_bg.png")
const COMBAT_BG = preload("res://assets/backgrounds/combat_bg.png")

var current_background: Control

func setup_for_scene(scene_type: String) -> void:
	get_children().all(remove_child)
	print("Background System: Setting up background for ", scene_type)
	
	var background: Control
	
	match scene_type:
		"MainMenu":
			background = TextureRect.new()
			background.texture = MAIN_MENU_BG
		"Combat":
			background = TextureRect.new()
			background.texture = COMBAT_BG
		_:
			background = ColorRect.new()
			background.color = Color.DARK_TURQUOISE
	
	configure_and_set(background)
	
func setup_background(backgroundResource: Resource) -> void:
	get_children().all(remove_child)
	print("Background System: Setting up background for encounter")
	
	var background: Control
	
	var encounterBackground = backgroundResource
	if encounterBackground:
		background = TextureRect.new()
		background.texture = encounterBackground
	else:
		background = ColorRect.new()
		background.color = Color.DARK_TURQUOISE
	
	configure_and_set(background)

func configure_and_set(background: Control) -> void:
	if background is TextureRect:
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.z_index = -1
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(background)
	current_background = background
