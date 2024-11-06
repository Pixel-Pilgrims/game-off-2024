extends Node

@onready var combat_scene = preload("res://scenes/combat.tscn")
@onready var menu_scene = preload("res://scenes/menus/main_menu.tscn")
@onready var home_base_scene = preload("res://scenes/home_base.tscn")

var current_scene: Node = null

func _ready():
	var ui_scale_manager = Node.new()
	ui_scale_manager.name = "UIScaleManager"
	ui_scale_manager.set_script(load("res://scripts/managers/ui_scale_manager.gd"))
	add_child(ui_scale_manager)
	# Ensure config is applied before showing the menu
	await get_tree().create_timer(0.1).timeout
	show_main_menu()

func cleanup_current_scene() -> void:
	print("Main: Cleaning up current scene")
	AdventureSystem.cleanup()
	if current_scene:
		remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null

func transition_to_scene(new_scene: Node) -> void:
	print("Transitioning to new scene: ", new_scene.name)
	cleanup_current_scene()
	
	print("Adding new scene: ", new_scene.name)
	current_scene = new_scene
	add_child(current_scene)

func show_main_menu() -> void:
	print("Showing main menu")
	var new_menu = menu_scene.instantiate()
	call_deferred("transition_to_scene", new_menu)

func start_combat() -> void:
	var new_combat = combat_scene.instantiate()
	call_deferred("transition_to_scene", new_combat)

func start_home_base() -> void:
	var new_home = home_base_scene.instantiate()
	call_deferred("transition_to_scene", new_home)

func handle_new_game() -> void:
	GameState.start_new_run()
	var new_game_cutscene = load("res://resources/cutscenes/new_game/new_game_cutscene.tres")
	cleanup_current_scene()
	
	# Start the cutscene
	CutsceneSystem.play_cutscene(new_game_cutscene, func():
		# After cutscene, start tutorial
		var ingame_tutorial_adventure = load("res://resources/adventures/ingame_tutorial/adventure_map.tres")
		AdventureSystem.start_adventure(ingame_tutorial_adventure)
		# Connect to adventure completion if not already connected
		if not AdventureSystem.adventure_completed.is_connected(_on_tutorial_completed):
			AdventureSystem.adventure_completed.connect(_on_tutorial_completed)
	)

func _on_tutorial_completed(_adventure: AdventureMapData) -> void:
	start_home_base()
