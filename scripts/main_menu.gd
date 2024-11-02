extends Control

func _ready():
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	print("start pressed")
	get_node("/root/Main").start_combat()

func _on_quit_pressed():
	print("quit pressed")
	get_tree().quit()
