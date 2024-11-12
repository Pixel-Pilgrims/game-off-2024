extends Button
class_name AudioButton

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	pressed.connect(_on_pressed)
	focus_entered.connect(_on_focus_entered)

func _on_mouse_entered() -> void:
	SoundEffectsSystem.play_sound("ui", "button_hover", -10.0)
	
func _on_pressed() -> void:
	SoundEffectsSystem.play_sound("ui", "button_click", -5.0)
	
func _on_focus_entered() -> void:
	SoundEffectsSystem.play_sound("ui", "button_hover", -10.0)
