extends Control

signal resume_pressed
signal quit_pressed

func _ready() -> void:
	hide()
	# Connect button signals
	var resume_button = $PanelContainer/MarginContainer/VBoxContainer/ResumeButton
	var quit_button = $PanelContainer/MarginContainer/VBoxContainer/QuitButton
	
	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)
	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()

func open() -> void:
	show()
	$PanelContainer/MarginContainer/VBoxContainer/ResumeButton.grab_focus()

func close() -> void:
	hide()
