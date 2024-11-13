# block_indicator.gd
extends Control
class_name BlockIndicator

@onready var block_label = $BlockLabel

const CIRCLE_COLOR = Color("2b4066")  # Dark blue
const ANIMATION_DURATION = 0.3

var current_block: int = 0
var tween: Tween

func _draw() -> void:
	var center = size / 2
	var radius = min(size.x, size.y) / 2
	draw_circle(center, radius, CIRCLE_COLOR)

func set_block(value: int) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		func(v): _update_block(v),
		current_block,
		value,
		ANIMATION_DURATION
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	current_block = value
	visible = value > 0

func _update_block(value: int) -> void:
	block_label.text = str(round(value))
	queue_redraw()
