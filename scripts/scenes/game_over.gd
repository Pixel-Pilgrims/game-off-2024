extends Control

signal continue_pressed

func _ready() -> void:
	# Disable inputs behind the game over screen
	mouse_filter = Control.MOUSE_FILTER_STOP
	$CenterContainer/VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed() -> void:
	continue_pressed.emit()
	
func open() -> void:
	show()
	$CenterContainer/VBoxContainer/ContinueButton.grab_focus()
