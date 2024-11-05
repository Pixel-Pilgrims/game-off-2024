# adventure_system.gd
extends Node

signal adventure_started(adventure_data: AdventureMapData)
signal encounter_selected(node: EncounterNodeData)
signal encounter_completed(node: EncounterNodeData)
signal adventure_completed(adventure_data: AdventureMapData)

const COMBAT_SCENE = preload("res://scenes/combat.tscn")
const ADVENTURE_MAP_SCENE = preload("res://scenes/adventure_map.tscn")

var current_adventure: AdventureMapData
var current_node: EncounterNodeData
var current_map_instance: Node

func start_adventure(adventure_data: AdventureMapData) -> void:
	current_adventure = adventure_data
	current_node = null
	
	# Emit signal for any listeners
	adventure_started.emit(adventure_data)
	
	# Create and show the adventure map
	if current_map_instance:
		current_map_instance.queue_free()
	
	current_map_instance = ADVENTURE_MAP_SCENE.instantiate()
	get_tree().root.add_child(current_map_instance)
	
	# Initialize the map with our adventure data
	current_map_instance.init_adventure(adventure_data)
	
	# Check if we should auto-start an encounter
	if adventure_data.auto_start and adventure_data.rootEncounterNode.childNodes.size() > 0:
		# Hide the map immediately if we're auto-starting
		current_map_instance.hide()
		_auto_start_first_encounter(adventure_data.rootEncounterNode)
	else:
		current_map_instance.show()

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
		for stage in current_map_instance.get_all_nodes():
			for potential_parent in stage:
				if potential_parent.childNodes.has(node) and potential_parent.completed:
					has_completed_parent = true
					break
		if not has_completed_parent:
			return false
	
	return true

func complete_current_encounter() -> void:
	if current_node:
		current_node.completed = true
		encounter_completed.emit(current_node)
		current_map_instance.update_map()
		adventure_completed.emit(current_adventure)
		# Save progress if needed
		# GameState.save_game()

func start_combat(combat_node: CombatEncounterNodeData) -> void:
	var combat_scene = COMBAT_SCENE.instantiate()
	
	# Get the enemy container
	var enemy_container = combat_scene.get_node("Enemy").get_parent()
	# Remove the default enemy
	enemy_container.remove_child(combat_scene.get_node("Enemy"))
	
	# Create an HBoxContainer for multiple enemies
	var enemies_container = HBoxContainer.new()
	enemies_container.alignment = BoxContainer.ALIGNMENT_CENTER
	enemies_container.add_theme_constant_override("separation", 20)
	enemy_container.add_child(enemies_container)
	
	# Add each enemy from the combat node
	for enemy_data in combat_node.enemies:
		var enemy_instance = enemy_data.enemy_scene.instantiate()
		enemies_container.add_child(enemy_instance)
		# Setup enemy with its data if needed
		if enemy_instance.has_method("setup"):
			enemy_instance.setup(enemy_data)
	
	get_tree().root.add_child(combat_scene)
	current_map_instance.hide()

func start_event(event_node: EventEncounterNodeData) -> void:
	var event_scene = event_node.eventScene.instantiate()
	# Setup event scene with any necessary data from event_node
	get_tree().root.add_child(event_scene)
	current_map_instance.hide()

func handle_finish_encounter(finish_node: FinishEncounterNodeData) -> void:
	var finish_scene = finish_node.finishScene.instantiate()
	get_tree().root.add_child(finish_scene)
	current_map_instance.hide()

func return_to_map() -> void:
	current_map_instance.show()

# Utility functions for other systems to use
func get_current_adventure() -> AdventureMapData:
	return current_adventure

func get_current_node() -> EncounterNodeData:
	return current_node

func is_node_available(node: EncounterNodeData) -> bool:
	return can_select_encounter(node)
