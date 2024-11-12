# scripts/systems/adventure_system.gd
extends Node

signal adventure_started(adventure_data: AdventureMapData)
signal encounter_selected(node: EncounterNodeData)
signal encounter_completed(node: EncounterNodeData)
signal adventure_completed(adventure_data: AdventureMapData)

const COMBAT_SCENE = preload("res://scenes/combat.tscn")
const ADVENTURE_MAP_SCENE = preload("res://scenes/adventure_map.tscn")
const ENEMY_SCENE = preload("res://scenes/enemies/enemy.tscn")

var current_adventure: AdventureMapData
var current_node: EncounterNodeData
var current_scene: Node
var map_instance: Node

func cleanup() -> void:
	print("Adventure System: Cleaning up...")
	if is_instance_valid(current_scene):
		print("Removing current scene")
		if current_scene.get_parent():
			current_scene.get_parent().call_deferred("remove_child", current_scene)
			current_scene.call_deferred("queue_free")
		current_scene = null
		
	if is_instance_valid(map_instance):
		print("Removing map instance")
		if map_instance.get_parent():
			map_instance.get_parent().call_deferred("remove_child", map_instance)
			map_instance.call_deferred("queue_free")
		map_instance = null
		
	current_node = null

func start_adventure(adventure_data: AdventureMapData) -> void:
	print("Starting new adventure")
	cleanup()  # Clean up any existing adventure first
	current_adventure = adventure_data
	current_node = null
	
	adventure_started.emit(adventure_data)
	
	if adventure_data.auto_start and adventure_data.rootEncounterNode.childNodes.size() > 0:
		_auto_start_first_encounter(adventure_data.rootEncounterNode)
	else:
		show_map()

func show_map() -> void:
	if current_scene or map_instance:
		cleanup()
		await get_tree().process_frame
	
	print("Creating new adventure map")
	map_instance = ADVENTURE_MAP_SCENE.instantiate()
	var main = get_node("/root/Main")
	main.call_deferred("add_child", map_instance)
	
	await get_tree().process_frame
	var adventure_manager = map_instance.get_node("AdventureManager")
	if adventure_manager:
		print("Initializing adventure map")
		adventure_manager.init_adventure(current_adventure)
		var encounter_nodes = get_tree().get_nodes_in_group("encounter_nodes")
		for node in encounter_nodes:
			node.connect('node_clicked', select_encounter)
	else:
		push_error("AdventureManager not found in map instance")

func _auto_start_first_encounter(start_node: StartEncounterNodeData) -> void:
	if start_node.childNodes.size() > 0:
		var first_encounter = start_node.childNodes[0]
		select_encounter(first_encounter)

func select_encounter(encounter_node: EncounterNodeData) -> void:
	if not can_select_encounter(encounter_node):
		return
		
	print("Selecting encounter: ", encounter_node.get_class())
	current_node = encounter_node
	encounter_selected.emit(encounter_node)
	
	if is_instance_valid(map_instance):
		if map_instance.get_parent():
			map_instance.get_parent().call_deferred("remove_child", map_instance)
			map_instance.call_deferred("queue_free")
		map_instance = null
	
	if encounter_node is CombatEncounterNodeData:
		start_combat(encounter_node)
	elif encounter_node is EventEncounterNodeData:
		start_event(encounter_node)
	elif encounter_node is FinishEncounterNodeData:
		handle_finish_encounter(encounter_node)

func can_select_encounter(node: EncounterNodeData) -> bool:
	if node.completed:
		return false
		
	if not node is StartEncounterNodeData:
		var has_completed_parent = false
		for potential_parent in _get_all_parent_nodes(node):
			if potential_parent.completed:
				has_completed_parent = true
				break
		if not has_completed_parent:
			return false
	
	return true

func _get_all_parent_nodes(node: EncounterNodeData) -> Array[EncounterNodeData]:
	var parents: Array[EncounterNodeData] = []
	_find_parents_recursive(current_adventure.rootEncounterNode, node, parents)
	return parents

func _find_parents_recursive(current: EncounterNodeData, target: EncounterNodeData, parents: Array[EncounterNodeData]) -> bool:
	for child in current.childNodes:
		if child == target:
			parents.append(current)
			return true
		if _find_parents_recursive(child, target, parents):
			parents.append(current)
			return true
	return false

func complete_current_encounter() -> void:
	if not current_node:
		return
		
	print("Completing encounter: ", current_node.get_class())
	current_node.completed = true
	encounter_completed.emit(current_node)
	
	# Check if this was the final encounter
	if is_final_encounter(current_node):
		print("Final encounter completed, transitioning to home base")
		adventure_completed.emit(current_adventure)
		# Transition to home base
		var main = get_node("/root/Main")
		if main.has_method("start_home_base"):
			main.start_home_base()
	else:
		call_deferred("_handle_encounter_completion")

func is_final_encounter(node: EncounterNodeData) -> bool:
	# Check if this node only leads to finish nodes or has no children
	if node.childNodes.is_empty():
		return true
	
	for child in node.childNodes:
		if not child is FinishEncounterNodeData:
			return false
	return true

func _handle_encounter_completion() -> void:
	if is_instance_valid(current_scene):
		if current_scene.get_parent():
			current_scene.get_parent().call_deferred("remove_child", current_scene)
			current_scene.call_deferred("queue_free")
		current_scene = null
	
	await get_tree().process_frame
	print("Showing map after encounter completion")
	show_map()

func start_combat(combat_node: CombatEncounterNodeData) -> void:
	print("Starting combat encounter")
	BackgroundSystem.setup_background(combat_node.background)
	var main = get_node("/root/Main")
	current_scene = COMBAT_SCENE.instantiate()
	
	var enemies_container = current_scene.get_node("EnemiesContainer")
	
	# Calculate spacing based on number of enemies
	var num_enemies = combat_node.enemies.size()
	var SPACING = 300  # Horizontal spacing between enemies
	var total_width = (num_enemies - 1) * SPACING
	var start_x = -total_width / 2  # Center the group of enemies
	
	# Spawn enemies with proper spacing
	for i in range(num_enemies):
		var enemy_data = combat_node.enemies[i]
		var enemy_scene = ENEMY_SCENE.instantiate();
		var enemy_instance = enemy_data.enemy_scene.instantiate()
		enemy_scene.add_child(enemy_instance)
		enemies_container.add_child(enemy_scene)
		
		# Position the enemy
		enemy_scene.position.x = start_x + (i * SPACING)
		
		if enemy_scene.has_method("setup"):
			enemy_scene.setup(enemy_data)
	
	main.call_deferred("add_child", current_scene)

func start_event(event_node: EventEncounterNodeData) -> void:
	print("Starting event encounter")
	BackgroundSystem.setup_background(event_node.background)
	if event_node.eventScene:
		var main = get_node("/root/Main")
		current_scene = event_node.eventScene.instantiate()
		main.call_deferred("add_child", current_scene)
	else:
		print("Warning: Event node has no scene assigned")
		complete_current_encounter()

func handle_finish_encounter(finish_node: FinishEncounterNodeData) -> void:
	print("Starting finish encounter")
	if finish_node.finishScene:
		var main = get_node("/root/Main")
		current_scene = finish_node.finishScene.instantiate()
		main.call_deferred("add_child", current_scene)
	else:
		print("Completing adventure without finish scene")
		complete_current_encounter()

func return_to_map() -> void:
	if not (current_node is FinishEncounterNodeData):
		if is_instance_valid(current_scene):
			if current_scene.get_parent():
				current_scene.get_parent().call_deferred("remove_child", current_scene)
				current_scene.call_deferred("queue_free")
			current_scene = null
		show_map()

func get_current_adventure() -> AdventureMapData:
	return current_adventure

func get_current_node() -> EncounterNodeData:
	return current_node

func is_node_available(node: EncounterNodeData) -> bool:
	return can_select_encounter(node)
