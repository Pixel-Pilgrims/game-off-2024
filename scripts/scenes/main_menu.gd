# main_menu.gd
extends Control

const OPTIONS_SCENE = preload("res://scenes/menus/options_menu.tscn")
const HOME_BASE_SCENE = preload("res://scripts/scenes/home_base.tscn")

func _ready():
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/ContinueButton.pressed.connect(_on_continue_button_pressed)
	$CenterContainer/VBoxContainer/Options.pressed.connect(_on_options_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	# Enable menu when it's first shown
	enable_menu()

func _on_start_pressed():
	print("start pressed")
	# Disable menu interaction before starting cutscene
	disable_menu()
	GameState.start_new_run()
	var new_game_cutscene = load("res://resources/cutscenes/new_game/new_game_cutscene.tres")
	$CutsceneSystem.play_cutscene(new_game_cutscene, start_ingame_tutorial)
	
func start_ingame_tutorial() -> void:
	var ingame_tutorial_adventure = load("res://resources/adventures/ingame_tutorial/adventure_map.tres")
	AdventureSystem.start_adventure(ingame_tutorial_adventure)
	AdventureSystem.adventure_completed.connect(_on_ingame_tutorial_completed)
	
func _on_ingame_tutorial_completed(adventure: AdventureMapData):
	get_node("/root/Main").start_home_base()
	

func _on_quit_pressed():
	print("quit pressed")
	GameState.save_game()
	get_tree().quit()

func _on_continue_button_pressed() -> void:
	print("continue pressed")
	GameState.load_game()
	get_node("/root/Main").start_home_base()

func _on_options_pressed() -> void:
	var options = OPTIONS_SCENE.instantiate()
	add_child(options)
	# Hide the main menu buttons while in options
	$CenterContainer.hide()
	# Connect to know when to show the buttons again
	options.options_closed.connect(_on_options_closed)

func _on_options_closed() -> void:
	$CenterContainer.show()
	
func disable_menu() -> void:
	# Disable all buttons
	for button in $CenterContainer/VBoxContainer.get_children():
		if button is Button:
			button.disabled = true
	
	# Make menu non-interactive
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Optional: fade the menu visually
	modulate = Color(1, 1, 1, 0.5)

func enable_menu() -> void:
	# Enable all buttons that should be enabled
	for button in $CenterContainer/VBoxContainer.get_children():
		if button is Button:
			# Skip buttons that should remain disabled (like Options or Continue if not available)
			if button.name == "ContinueButton" and not has_save_game():
				continue
			button.disabled = false
	
	# Make menu interactive again
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Restore full opacity
	modulate = Color(1, 1, 1, 1)
	
	# Focus the Start button
	$CenterContainer/VBoxContainer/StartButton.grab_focus()

func has_save_game() -> bool:
	return FileAccess.file_exists("user://gamestate.save")
