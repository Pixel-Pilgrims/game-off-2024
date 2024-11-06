extends Control

signal node_clicked(node_data: EncounterNodeData)

var node_data: EncounterNodeData

@onready var circle: ColorRect = $CenterContainer/VBoxContainer/CenterContainer/Circle
@onready var label: Label = $CenterContainer/VBoxContainer/Label

const BASE_NODE_COLOR := Color("4a4a4a")
const START_NODE_COLOR := Color("1a531a")
const FINISH_NODE_COLOR := Color("531a1a")
const COMPLETED_COLOR := Color("4a821a")
const HOVER_TINT := Color(1.2, 1.2, 1.2, 1)

func _ready() -> void:
	custom_minimum_size = Vector2(100, 100)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Setup mouse handling
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# If we were set up before _ready, update appearance now
	if node_data:
		update_appearance()

func setup(data: EncounterNodeData) -> void:
	node_data = data
	if is_node_ready():
		update_appearance()

func get_node_data() -> EncounterNodeData:
	return node_data

func set_start_node() -> void:
	if not is_node_ready():
		await ready
	circle.set_node_color(START_NODE_COLOR)
	label.text = "Start"

func set_finish_node() -> void:
	if not is_node_ready():
		await ready
	circle.set_node_color(FINISH_NODE_COLOR)
	label.text = "Final"

func set_completed() -> void:
	if not is_node_ready():
		await ready
	circle.set_node_color(COMPLETED_COLOR)

func update_appearance() -> void:
	if not is_node_ready():
		await ready
		
	if node_data.completed:
		set_completed()
	elif node_data is StartEncounterNodeData:
		set_start_node()
	elif node_data is FinishEncounterNodeData:
		set_finish_node()
	else:
		circle.set_node_color(BASE_NODE_COLOR)
		label.text = "Encounter"

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			node_clicked.emit(node_data)

func _on_mouse_entered() -> void:
	modulate = HOVER_TINT

func _on_mouse_exited() -> void:
	modulate = Color.WHITE
