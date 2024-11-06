extends Node

const PAUSE_MENU = preload("res://scenes/pause_menu.tscn")

var pause_menu: Control = null
var is_paused: bool = false

func _ready() -> void:
	setup_pause_menu()
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup_pause_menu() -> void:
	if pause_menu == null:
		pause_menu = PAUSE_MENU.instantiate()
		add_child(pause_menu)
		var ui_scale_manager = get_node("/root/Main/UIScaleManager")
		ui_scale_manager.register_ui_root(pause_menu)
		pause_menu.resume_pressed.connect(_on_resume)
		pause_menu.quit_pressed.connect(_on_quit)
		pause_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		pause_menu.open()
	else:
		pause_menu.close()

func _on_resume() -> void:
	toggle_pause()

func _on_quit() -> void:
	print("Pause Menu: Handling quit to main menu")
	# Unpause the game
	is_paused = false
	get_tree().paused = false
	pause_menu.hide()
	
	# Let Main handle the scene transition
	var main = get_node("/root/Main")
	if main:
		main.show_main_menu()
	else:
		print("ERROR: Couldn't find Main node!")
