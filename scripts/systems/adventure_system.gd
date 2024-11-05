extends Node

signal adventure_started(adventure_data: AdventureMapData)
signal encounter_selected(node: EncounterNodeData)
signal encounter_completed(node: EncounterNodeData)
signal adventure_completed(adventure_data: AdventureMapData)

const COMBAT_SCENE = preload("res://scenes/combat.tscn")
const ADVENTURE_MAP_SCENE = preload("res://scenes/adventure_map.tscn")

var current_adventure: AdventureMapData
var current_node: EncounterNodeData
var current_combat_scene: Node

func start_adventure(adventure_data: AdventureMapData) -> void:
	current_adventure = adventure_data
	current_node = null
	
	adventure_started.emit(adventure_data)
	
	if adventure_data.auto_start and adventure_data.rootEncounterNode.childNodes.size() > 0:
		_auto_start_first_encounter(adventure_data.rootEncounterNode)
	else:
		show_map()

func show_map() -> void:
	var map_instance = ADVENTURE_MAP_SCENE.instantiate()
	get_tree().root.add_child(map_instance)
	map_instance.get_node("AdventureManager").init_adventure(current_adventure)

func _auto_start_first_encounter(start_node: StartEncounterNodeData) -> void:
	# Get the first available child node
	if start_node.childNodes.size() > 0:
		var first_encounter = start_node.childNodes[0]
		select_encounter(first_encounter)

func select_encounter(encounter_node: EncounterNodeData) -> void:
	if not can_select_encounter(encounter_node):
		return
		
	current_node = encounter_node
	encounter_selected.emit(encounter_node)
	
	# Handle different encounter types
	if encounter_node is CombatEncounterNodeData:
		start_combat(encounter_node)
	elif encounter_node is EventEncounterNodeData:
		start_event(encounter_node)
	elif encounter_node is FinishEncounterNodeData:
		handle_finish_encounter(encounter_node)

func can_select_encounter(node: EncounterNodeData) -> bool:
	# Can't select already completed encounters
	if node.completed:
		return false
		
	# Must have a completed parent (unless it's the start node)
	if not node is StartEncounterNodeData:
		var has_completed_parent = false
		# Check all parent nodes directly
		for potential_parent in _get_all_parent_nodes(node):
			if potential_parent.completed:
				has_completed_parent = true
				break
		if not has_completed_parent:
			return false
	
	return true

func _get_all_parent_nodes(node: EncounterNodeData) -> Array[EncounterNodeData]:
	var parents: Array[EncounterNodeData] = []
	
	# Start from the root and traverse the tree
	_find_parents_recursive(current_adventure.rootEncounterNode, node, parents)
	
	return parents

func _find_parents_recursive(current: EncounterNodeData, target: EncounterNodeData, parents: Array[EncounterNodeData]) -> bool:
	# Check if any of this node's children is our target
	for child in current.childNodes:
		if child == target:
			parents.append(current)
			return true
		# Recursively check this child's children
		if _find_parents_recursive(child, target, parents):
			return true
	
	return false

func complete_current_encounter() -> void:
	if current_node:
		current_node.completed = true
		encounter_completed.emit(current_node)
		
		if current_node is FinishEncounterNodeData:
			adventure_completed.emit(current_adventure)
		else:
			# If we have a current combat/event scene, remove it
			if current_combat_scene:
				current_combat_scene.queue_free()
				current_combat_scene = null
			
			await get_tree().process_frame
			show_map()

func start_combat(combat_node: CombatEncounterNodeData) -> void:
	var combat_scene = COMBAT_SCENE.instantiate()
	
	# Get the enemies container
	var enemies_container = combat_scene.get_node("EnemiesContainer")
	
	# Add each enemy from the combat node
	for enemy_data in combat_node.enemies:
		var enemy_instance = enemy_data.enemy_scene.instantiate()
		enemies_container.add_child(enemy_instance)
		# Setup enemy with its data if needed
		if enemy_instance.has_method("setup"):
			enemy_instance.setup(enemy_data)
	
	get_tree().root.add_child(combat_scene)
	current_combat_scene = combat_scene

func start_event(event_node: EventEncounterNodeData) -> void:
	var event_scene = event_node.eventScene.instantiate()
	# Setup event scene with any necessary data from event_node
	get_tree().root.add_child(event_scene)
	current_combat_scene = event_scene

func handle_finish_encounter(finish_node: FinishEncounterNodeData) -> void:
	var finish_scene = finish_node.finishScene.instantiate()
	get_tree().root.add_child(finish_scene)
	current_combat_scene = finish_scene

func return_to_map() -> void:
	# Only return to map if we aren't finished
	if not (current_node is FinishEncounterNodeData):
		show_map()

# Utility functions for other systems to use
func get_current_adventure() -> AdventureMapData:
	return current_adventure

func get_current_node() -> EncounterNodeData:
	return current_node

func is_node_available(node: EncounterNodeData) -> bool:
	return can_select_encounter(node)
