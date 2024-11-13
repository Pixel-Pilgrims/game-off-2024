# intent_display.gd
extends Control
class_name IntentDisplay

@onready var icon = $Icon
@onready var value_label = $ValueLabel
@onready var animation_player = $AnimationPlayer

var tween: Tween

func display_intent(ability: AbilityData) -> void:
	if not ability:
		hide()
		return
		
	show()
	
	if ability.icon:
		icon.texture = ability.icon
	
	value_label.text = ability.name
	
	# Animate in
	if tween:
		tween.kill()
	
	modulate = Color.TRANSPARENT
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Bounce animation
	var start_pos = position
	tween.parallel().tween_property(self, "position:y", start_pos.y - 20, 0.3)
	tween.tween_property(self, "position:y", start_pos.y, 0.2)
