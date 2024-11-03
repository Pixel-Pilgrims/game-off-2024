# main_menu.gd
extends Control

const OPTIONS_SCENE = preload("res://scenes/menus/options_menu.tscn")

func _ready():
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$CenterContainer/VBoxContainer/Options.pressed.connect(_on_options_pressed)
	
	# Enable the options button since we now have functionality for it
	$CenterContainer/VBoxContainer/Options.disabled = false
	$CenterContainer/VBoxContainer/ContinueButton.pressed.connect(_on_continue_button_pressed)

func _on_start_pressed():
	print("start pressed")
	GameState.start_new_run()
	var new_game_cutscene = load("res://resources/cutscenes/new_game/new_game_cutscene.tres")
	$CutsceneSystem.play_cutscene(new_game_cutscene, start_combat)
	
func start_combat() -> void:
	get_node("/root/Main").start_combat()

func _on_quit_pressed():
	print("quit pressed")
	GameState.save_game()
	get_tree().quit()

func _on_continue_button_pressed() -> void:
	print("continue pressed")
	GameState.load_game()
	start_combat()

func _on_options_pressed() -> void:
	var options = OPTIONS_SCENE.instantiate()
	add_child(options)
	# Hide the main menu buttons while in options
	$CenterContainer.hide()
	# Connect to know when to show the buttons again
	options.options_closed.connect(_on_options_closed)

func _on_options_closed() -> void:
	$CenterContainer.show()
