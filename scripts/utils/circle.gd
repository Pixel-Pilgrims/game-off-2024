extends ColorRect

var hover_tint := Color(1.2, 1.2, 1.2, 1)
var base_color: Color
var is_hovered := false

func _ready() -> void:
	# Store the initial color as base color
	base_color = color
	# Make the ColorRect transparent
	color = Color.TRANSPARENT
	# Connect to mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exit)

func _draw() -> void:
	var center = size / 2
	var radius = min(size.x, size.y) / 2
	var circle_color = base_color * (hover_tint if is_hovered else Color.WHITE)
	draw_circle(center, radius, circle_color)

func set_node_color(new_color: Color) -> void:
	base_color = new_color
	queue_redraw()

func _on_mouse_entered() -> void:
	is_hovered = true
	queue_redraw()

func _on_mouse_exit() -> void:
	is_hovered = false
	queue_redraw()
