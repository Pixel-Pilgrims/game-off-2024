extends Control

func _ready():
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	print("start pressed")
	GameState.start_new_run()
	var new_game_cutscene = load("res://resources/cutscenes/new_game/new_game_cutscene.tres")
	$CutsceneSystem.play_cutscene(new_game_cutscene, start_combat)
	
# TODO: combat should not be started from the main menu, continue should go to the 'home-base'
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
	pass # Replace with function body.
