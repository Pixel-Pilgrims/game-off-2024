extends Node

const PAUSE_MENU = preload("res://scenes/pause_menu.tscn")

var pause_menu: Control
var is_paused: bool = false

func _ready() -> void:
	pause_menu = PAUSE_MENU.instantiate()
	add_child(pause_menu)
	# Register with UI scaling system
	var ui_scale_manager = get_node("/root/Main/UIScaleManager")
	ui_scale_manager.register_ui_root(pause_menu)
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu = PAUSE_MENU.instantiate()
	add_child(pause_menu)
	pause_menu.resume_pressed.connect(_on_resume)
	pause_menu.quit_pressed.connect(_on_quit)

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
	# You might want to confirm before quitting
	get_tree().paused = false
	get_node("/root/Main").show_main_menu()
