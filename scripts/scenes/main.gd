extends Node

@onready var combat_scene = preload("res://scenes/combat.tscn")
@onready var menu_scene = preload("res://scenes/menus/main_menu/main_menu.tscn")

var current_scene: Node = null

func _ready():
	show_main_menu()

func show_main_menu():
	if current_scene:
		current_scene.queue_free()
	current_scene = menu_scene.instantiate()
	add_child(current_scene)

func start_combat():
	if current_scene:
		current_scene.queue_free()
	current_scene = combat_scene.instantiate()
	add_child(current_scene)

func combat_won():
	print("Combat won")
	show_main_menu()