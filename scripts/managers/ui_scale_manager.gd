extends Node

var current_scale: float = 1.0
const BASE_RESOLUTION := Vector2(1920, 1080)

func _ready() -> void:
	# Connect to signals
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	ConfigManager.resolution_changed.connect(_on_resolution_changed)
	ConfigManager.window_mode_changed.connect(_on_window_mode_changed)
	
	# Initial setup
	call_deferred("_do_initial_setup")

func _do_initial_setup() -> void:
	await get_tree().process_frame
	_update_ui_scale()

func _on_viewport_size_changed() -> void:
	_update_ui_scale()

func _on_resolution_changed(_new_resolution: Vector2) -> void:
	_update_ui_scale()

func _on_window_mode_changed(_is_fullscreen: bool) -> void:
	_update_ui_scale()

func register_ui_root(control: Control) -> void:
	control.pivot_offset = control.size / 2
	_setup_control(control)
	_update_ui_scale()

func _update_ui_scale() -> void:
	var viewport_size := DisplayServer.window_get_size()
	var scale_x := viewport_size.x / float(BASE_RESOLUTION.x)
	var scale_y := viewport_size.y / float(BASE_RESOLUTION.y)
	current_scale = min(scale_x, scale_y)
	
	_scale_ui_recursive(get_tree().root)

func _scale_ui_recursive(node: Node) -> void:
	if node is Control:
		_setup_control(node)
	
	for child in node.get_children():
		_scale_ui_recursive(child)

func _setup_control(control: Control) -> void:
	if control is CenterContainer:
		var viewport_size = DisplayServer.window_get_size()
		control.custom_minimum_size = Vector2.ZERO
		control.anchor_right = 1.0
		control.anchor_bottom = 1.0
		control.offset_right = 0
		control.offset_bottom = 0
		control.position = Vector2.ZERO
		control.size = viewport_size
		
		# Update children anchoring
		for child in control.get_children():
			if child is Control:
				child.anchor_left = 0.5
				child.anchor_right = 0.5
				child.anchor_top = 0.5
				child.anchor_bottom = 0.5
				child.position = -child.size / 2
