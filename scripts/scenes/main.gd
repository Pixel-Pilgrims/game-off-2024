# main.gd
extends Node

@onready var combat_scene = preload("res://scenes/combat.tscn")
@onready var menu_scene = preload("res://scenes/menus/main_menu.tscn")

var current_scene: Node = null

func _ready():
	var ui_scale_manager = Node.new()
	ui_scale_manager.name = "UIScaleManager"  # Named for easy reference
	ui_scale_manager.set_script(load("res://scripts/managers/ui_scale_manager.gd"))
	add_child(ui_scale_manager)
	# Ensure config is applied before showing the menu
	await get_tree().create_timer(0.1).timeout
	show_main_menu()

func show_main_menu():
	if current_scene:
		current_scene.queue_free()
	current_scene = menu_scene.instantiate()
	add_child(current_scene)
	# The menu will enable itself in its _ready() function

func start_combat():
	if current_scene:
		current_scene.queue_free()
	current_scene = combat_scene.instantiate()
	add_child(current_scene)

func combat_won():
	print("Combat won")
	show_main_menu()
