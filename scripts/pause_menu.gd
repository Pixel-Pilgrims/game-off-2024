extends Control

signal resume_pressed
signal quit_pressed

func _ready() -> void:
	hide()
	$PanelContainer/MarginContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$PanelContainer/MarginContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_resume_pressed() -> void:
	resume_pressed.emit()
	hide()

func _on_quit_pressed() -> void:
	quit_pressed.emit()

func open() -> void:
	show()
	$PanelContainer/MarginContainer/VBoxContainer/ResumeButton.grab_focus()

func close() -> void:
	hide()
