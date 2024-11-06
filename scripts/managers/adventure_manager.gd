extends Node

@export var adventure: AdventureMapData
@onready var adventureStagesContainer: HBoxContainer = $"../ScrollContainer/AdventureStages"
@onready var lines_container: Node2D = $"../ScrollContainer/LinesContainer"
@onready var scroll_container = $"../ScrollContainer"

const NODE_SCENE = preload("res://scenes/encounter_node.tscn")
@export var COLUMN_SPACING = 400
@export var NODE_SPACING = 600
@export var NODE_SIZE = 100
@export var LINE_COLOR = Color("6b7280")
@export var LINE_WIDTH = 3.0
@export var DASH_LENGTH: float = 2.0
@export var GAP_LENGTH: float = 20.0

var last_scroll_pos: float = 0.0

func _ready() -> void:
	set_process(true)

func init_adventure(adventureResource: AdventureMapData):
	adventure = adventureResource
	BackgroundSystem.setup_background(null)
	drawMap()
	

func _process(_delta: float) -> void:
	# Check if scroll position has changed
	if scroll_container and lines_container:
		var current_scroll = scroll_container.scroll_horizontal
		if current_scroll != last_scroll_pos:
			lines_container.position.x = -current_scroll
			last_scroll_pos = current_scroll

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
	var node_positions = {}
	_gather_stages(adventure.rootEncounterNode, 0, stages, node_positions)
	
	# Calculate total width needed
	var total_width = COLUMN_SPACING * stages.size()
	adventureStagesContainer.custom_minimum_size.x = total_width
	
	# Create containers for each stage
	for stage_idx in range(stages.size()):
		var stage_nodes = stages[stage_idx]
		var stage_container = VBoxContainer.new()
		stage_container.custom_minimum_size.x = COLUMN_SPACING
		stage_container.alignment = BoxContainer.ALIGNMENT_CENTER
		stage_container.add_theme_constant_override("separation", NODE_SPACING)
		adventureStagesContainer.add_child(stage_container)
		
		# Add nodes to the stage
		for node_data in stage_nodes:
			var encounter_node = _create_encounter_node(node_data)
			stage_container.add_child(encounter_node)
			node_positions[node_data] = encounter_node
	
	# Center the content
	adventureStagesContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Draw connections after nodes are positioned
	await get_tree().process_frame
	_draw_all_connections(node_positions)

func _gather_stages(node: EncounterNodeData, depth: int, stages: Array, node_positions: Dictionary) -> void:
	# Ensure we have an array for this depth
	while stages.size() <= depth:
		stages.append([])
	
	# Only add node if it hasn't been added before
	if not node_positions.has(node):
		stages[depth].append(node)
		node_positions[node] = true
	
	# Process child nodes
	for child in node.childNodes:
		_gather_stages(child, depth + 1, stages, node_positions)

func _create_encounter_node(node_data: EncounterNodeData) -> Control:
	var node_instance = NODE_SCENE.instantiate()
	node_instance.setup(node_data)
	
	# Set consistent size
	node_instance.custom_minimum_size = Vector2(NODE_SIZE * 2, NODE_SIZE * 3)
	
	# Node type specific setup
	var node_circle = node_instance.get_node("CenterContainer/VBoxContainer/CenterContainer/Circle")
	
	if node_data is StartEncounterNodeData:
		node_instance.set_start_node()
		node_circle.color = Color("1a531a")
	elif node_data is FinishEncounterNodeData:
		node_instance.set_finish_node()
		node_circle.color = Color("531a1a")
	else:
		node_circle.color = Color("4a4a4a")
	
	if node_data.completed:
		node_instance.set_completed()
		node_circle.color = Color("4a821a")
	
	return node_instance

func _draw_all_connections(node_positions: Dictionary) -> void:
	# Draw connections directly from parent to child
	for parent_node in node_positions.keys():
		var parent_instance = node_positions[parent_node]
		if parent_instance is Control:  # Check if it's an actual node instance
			for child_data in parent_node.childNodes:
				var child_instance = node_positions.get(child_data)
				if child_instance is Control:
					_draw_connection(parent_instance, child_instance)

func _draw_connection(from_node: Control, to_node: Control) -> void:
	var line = Line2D.new()
	line.default_color = LINE_COLOR
	line.width = LINE_WIDTH
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Get the circles' centers in global coordinates
	var from_circle = from_node.get_node("CenterContainer/VBoxContainer/CenterContainer/Circle")
	var to_circle = to_node.get_node("CenterContainer/VBoxContainer/CenterContainer/Circle")
	
	var from_center = from_circle.get_global_rect().get_center()
	var to_center = to_circle.get_global_rect().get_center()
	
	# Convert points to lines_container's local coordinates, accounting for scroll
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
