extends ColorRect

func _draw() -> void:
	draw_circle(size / 2, size.x / 2, color)

func _ready() -> void:
	# Make the ColorRect transparent, we'll only show the circle
	color = Color.TRANSPARENT
