# main.gd
extends Node

var current_scene: Node = null
@onready var main_menu_scene = preload("res://scenes/menus/main_menu.tscn")
@onready var combat_scene = preload("res://scenes/Combat.tscn")
@onready var home_base_scene = preload("res://scenes/menus/homebase/homebase.tscn")

func _ready():
	# Ensure config is applied before showing the menu
	await get_tree().create_timer(0.1).timeout
	show_main_menu()
	
func show_main_menu():
	if current_scene:
		current_scene.queue_free()
	current_scene = menu_scene.instantiate()
	add_child(current_scene)
	
func switch_to_main_menu() -> void:
	switch_scene(main_menu_scene.instantiate())

func switch_to_home_base() -> void:
	switch_scene(home_base_scene.instantiate())

func start_combat() -> void:
	switch_scene(combat_scene.instantiate())

func switch_scene(new_scene: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	
	current_scene = new_scene
	add_child(current_scene)
