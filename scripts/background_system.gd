extends Node

# Preload the background textures
const MAIN_MENU_BG = preload("res://assets/backgrounds/main_menu_bg.webp")
const COMBAT_BG = preload("res://assets/backgrounds/combat_bg.webp")

func _ready():
	setup_background()

func setup_background():
	# Create a TextureRect node as the background
	var background = TextureRect.new()
	
	# Set it to fill the entire viewport
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Make sure it stays behind other elements
	background.z_index = -1
	
	# Ignore mouse input so controls underneath work
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Get the parent scene name directly
	var current_scene = get_parent().name
	print("Current scene: ", current_scene)  # Debug print
	
	# Set the texture based on the current scene
	if current_scene == "MainMenu":
		background.texture = MAIN_MENU_BG
	elif current_scene == "Combat":
		background.texture = COMBAT_BG
	
	# Set the stretch mode to cover the entire area while maintaining aspect ratio
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# Add the background as the first child
	add_child(background)
	move_child(background, 0)
