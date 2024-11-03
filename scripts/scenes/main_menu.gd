extends Control

func _ready():
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	print("start pressed")
	var new_game_cutscene = load("res://resources/cutscenes/new_game/new_game_cutscene.tres")
	$CutsceneSystem.play_cutscene(new_game_cutscene, start_combat)
	
func start_combat() -> void:
	get_node("/root/Main").start_combat()

func _on_quit_pressed():
	print("quit pressed")
	get_tree().quit()
