extends Node

signal adventure_started(adventure_data: AdventureMapData)
signal encounter_selected(node: EncounterNodeData)
signal encounter_completed(node: EncounterNodeData)
signal adventure_completed(adventure_data: AdventureMapData)

const COMBAT_SCENE = preload("res://scenes/combat.tscn")
const ADVENTURE_MAP_SCENE = preload("res://scenes/adventure_map.tscn")

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
	
	if current_node is FinishEncounterNodeData:
		adventure_completed.emit(current_adventure)
	else:
		call_deferred("_handle_encounter_completion")

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
	
	for enemy_data in combat_node.enemies:
		var enemy_instance = enemy_data.enemy_scene.instantiate()
		enemies_container.add_child(enemy_instance)
		if enemy_instance.has_method("setup"):
			enemy_instance.setup(enemy_data)
	
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