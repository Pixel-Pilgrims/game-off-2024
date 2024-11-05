extends Node

@export var adventure: AdventureMapData
@onready var adventureStagesContainer: HBoxContainer = $"../ScrollContainer/HBoxContainer/AdventureStages"
@onready var lines_container: Node2D = $"../ScrollContainer/HBoxContainer/LinesContainer"

const NODE_SCENE = preload("res://scenes/encounter_node.tscn")
@export var COLUMN_SPACING = 200
@export var NODE_SPACING = 120
@export var LINE_COLOR = Color("6b7280")
@export var LINE_WIDTH = 3.0
@export var DASH_LENGTH: float = 10.0
@export var GAP_LENGTH: float = 10.0

func init_adventure_from_resource(adventureResource: AdventureMapData) -> void:
	adventure = adventureResource
	drawMap()

func drawMap() -> void:
	# Clear existing nodes and lines
	for child in adventureStagesContainer.get_children():
		child.queue_free()
	for child in lines_container.get_children():
		child.queue_free()
	
	if not adventure or not adventure.rootEncounterNode:
		return
	
	# Create stages (columns) based on depth
	var stages = []
	_gather_stages(adventure.rootEncounterNode, 0, stages)
	
	# Create containers for each stage
	for stage_nodes in stages:
		var stage_container = VBoxContainer.new()
		stage_container.custom_minimum_size.x = COLUMN_SPACING
		stage_container.alignment = BoxContainer.ALIGNMENT_CENTER
		stage_container.add_theme_constant_override("separation", NODE_SPACING)
		adventureStagesContainer.add_child(stage_container)
		
		# Add nodes to the stage
		for node_data in stage_nodes:
			var encounter_node = _create_encounter_node(node_data)
			stage_container.add_child(encounter_node)
	
	# Draw all connections after nodes are positioned
	await get_tree().process_frame
	_draw_all_connections()

func _gather_stages(node: EncounterNodeData, depth: int, stages: Array) -> void:
	# Ensure we have an array for this depth
	while stages.size() <= depth:
		stages.append([])
	
	# Add node to its stage
	stages[depth].append(node)
	
	# Process child nodes
	for child in node.childNodes:
		_gather_stages(child, depth + 1, stages)

func _create_encounter_node(node_data: EncounterNodeData) -> Control:
	var node_instance = NODE_SCENE.instantiate()
	node_instance.setup(node_data)
	
	# Node type specific setup
	if node_data is StartEncounterNodeData:
		node_instance.set_start_node()
	elif node_data is FinishEncounterNodeData:
		node_instance.set_finish_node()
	
	if node_data.completed:
		node_instance.set_completed()
	
	return node_instance

func _draw_all_connections() -> void:
	var stages = adventureStagesContainer.get_children()
	
	for stage_idx in range(stages.size() - 1):  # Stop before last stage
		var current_stage = stages[stage_idx]
		var next_stage = stages[stage_idx + 1]
		
		for from_node in current_stage.get_children():
			var from_data = from_node.get_node_data()
			
			for child_data in from_data.childNodes:
				for to_node in next_stage.get_children():
					if to_node.get_node_data() == child_data:
						_draw_connection(from_node, to_node)

func _draw_connection(from_node: Control, to_node: Control) -> void:
	var line = Line2D.new()
	line.default_color = LINE_COLOR
	line.width = LINE_WIDTH
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Get the circles' centers in local coordinates relative to their common parent
	var from_circle = from_node.get_node("CenterContainer/VBoxContainer/Circle")
	var to_circle = to_node.get_node("CenterContainer/VBoxContainer/Circle")
	
	var from_center = from_circle.get_global_rect().get_center()
	var to_center = to_circle.get_global_rect().get_center()
	
	# Convert points to lines_container's local coordinates
	from_center = lines_container.to_local(from_center)
	to_center = lines_container.to_local(to_center)
	
	# Calculate control points for curve
	var control_offset = Vector2((to_center.x - from_center.x) * 0.5, 0)
	
	# Create dotted line points
	var points = _create_dotted_curve_points(from_center, to_center, control_offset)
	
	line.points = points
	lines_container.add_child(line)

func _create_dotted_curve_points(from: Vector2, to: Vector2, control_offset: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var curve = Curve2D.new()
	
	# Add points to create a bezier curve
	curve.add_point(from, Vector2.ZERO, control_offset)
	curve.add_point(to, -control_offset, Vector2.ZERO)
	
	# Settings for dash pattern
	var dash_length := DASH_LENGTH
	var gap_length := GAP_LENGTH
	var curve_length = curve.get_baked_length()
	
	# Always start with the first point
	points.append(from)
	
	# Calculate how many complete dash-gap pairs we need
	var segment_length = dash_length + gap_length
	var num_complete_segments = floor((curve_length - dash_length) / segment_length)
	
	# Create the middle dots
	for i in range(num_complete_segments):
		var pos = (i + 1) * segment_length
		points.append(curve.sample_baked(pos))
	
	# Always end with the last point
	points.append(to)
	
	return points
