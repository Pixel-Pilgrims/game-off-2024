extends Node
class_name CombatAnimator

signal animation_completed

# Animation constants
const HEALTH_CHANGE_DURATION = 0.4
const BLOCK_CHANGE_DURATION = 0.3
const ATTACK_WIND_UP = 0.3
const ATTACK_FOLLOW_THROUGH = 0.2
const DAMAGE_FLASH_DURATION = 0.2
const DAMAGE_SHAKE_DISTANCE = 10.0
const DEFAULT_TWEEN_TRANS = Tween.TRANS_EXPO
const DEFAULT_TWEEN_EASE = Tween.EASE_OUT

var is_animating := false
var sprite_original_position: Vector2
var current_tween: Tween

@onready var parent = get_parent()
@onready var visual = parent.get_node_or_null("Visual")

func _ready() -> void:
	# Store original position for attack animations
	if parent is Node2D:
		sprite_original_position = parent.position

func animate_damage_taken() -> Signal:
	if not visual:
		animation_completed.emit()
		return animation_completed

	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	is_animating = true
	current_tween = create_tween().set_parallel(true)
	
	# Flash white
	current_tween.tween_property(visual, "modulate", Color.WHITE, DAMAGE_FLASH_DURATION/2)
	current_tween.tween_property(visual, "modulate", Color.RED, DAMAGE_FLASH_DURATION/2)
	current_tween.chain().tween_property(visual, "modulate", Color.WHITE, DAMAGE_FLASH_DURATION/2)
	current_tween.chain().tween_property(visual, "modulate", Color(1,1,1,1), DAMAGE_FLASH_DURATION/2)
	
	# Shake effect
	var original_pos = visual.position
	var shake_positions = [
		original_pos + Vector2.RIGHT * DAMAGE_SHAKE_DISTANCE,
		original_pos + Vector2.LEFT * DAMAGE_SHAKE_DISTANCE,
		original_pos + Vector2.UP * DAMAGE_SHAKE_DISTANCE,
		original_pos + Vector2.DOWN * DAMAGE_SHAKE_DISTANCE,
		original_pos
	]
	
	for pos in shake_positions:
		current_tween.chain().tween_property(visual, "position", pos, 0.05)
	
	current_tween.finished.connect(func():
		# Ensure we reset to original state
		visual.position = original_pos
		visual.modulate = Color(1,1,1,1)
		is_animating = false
		animation_completed.emit()
	)
	
	return animation_completed

func animate_health_change(from: float, to: float, health_bar: HealthBar) -> Signal:
	is_animating = true
	var tween = create_tween()
	tween.tween_method(health_bar.set_health, from, to, HEALTH_CHANGE_DURATION)\
		.set_trans(DEFAULT_TWEEN_TRANS)\
		.set_ease(DEFAULT_TWEEN_EASE)
	tween.finished.connect(func():
		is_animating = false
		animation_completed.emit()
	)
	return animation_completed

func animate_block_change(from: float, to: float, health_bar: HealthBar) -> Signal:
	is_animating = true
	var tween = create_tween()
	tween.tween_method(health_bar.set_block, from, to, BLOCK_CHANGE_DURATION)\
		.set_trans(DEFAULT_TWEEN_TRANS)\
		.set_ease(DEFAULT_TWEEN_EASE)
	tween.finished.connect(func():
		is_animating = false
		animation_completed.emit()
	)
	return animation_completed

func animate_attack(target_node: Node2D) -> Signal:
	is_animating = true
	if not parent is Node2D:
		is_animating = false
		animation_completed.emit()
		return animation_completed
		
	var direction = (target_node.position - parent.position).normalized()
	var attack_offset = direction * 100  # Distance to move forward
	
	var tween = create_tween()
	# Wind up
	tween.tween_property(parent, "position", 
		sprite_original_position - (attack_offset * 0.3), 
		ATTACK_WIND_UP)
	# Attack lunge
	tween.tween_property(parent, "position",
		sprite_original_position + attack_offset,
		ATTACK_WIND_UP)
	# Return to position
	tween.tween_property(parent, "position",
		sprite_original_position,
		ATTACK_FOLLOW_THROUGH)
	
	tween.finished.connect(func():
		is_animating = false
		animation_completed.emit()
	)
	return animation_completed

func is_busy() -> bool:
	return is_animating
