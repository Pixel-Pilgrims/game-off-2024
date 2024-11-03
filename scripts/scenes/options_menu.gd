# options_menu.gd
extends Control

signal options_closed

# Scene References
@onready var fullscreen_toggle = %FullscreenToggle
@onready var resolution_dropdown = %ResolutionOptionButton
@onready var master_volume_slider = %VolumeSlider
@onready var mute_toggle = %MuteToggle
@onready var back_button = %BackButton

func _ready():
	setup_controls()
	load_settings()
	connect_signals()

func setup_controls():
	# Setup resolution dropdown
	for resolution in ConfigManager.resolutions:
		resolution_dropdown.add_item("%dx%d" % [resolution.x, resolution.y])
	
	# Setup volume slider
	master_volume_slider.min_value = -80
	master_volume_slider.max_value = 0
	
	# Load initial values
	fullscreen_toggle.button_pressed = ConfigManager.config.video.fullscreen
	resolution_dropdown.selected = ConfigManager.config.video.resolution_index
	master_volume_slider.value = ConfigManager.config.audio.master_volume
	mute_toggle.button_pressed = ConfigManager.config.audio.muted
	
	# Update resolution dropdown state based on fullscreen
	_update_resolution_dropdown_state()

func connect_signals():
	print("Connecting signals...") # Debug print
	fullscreen_toggle.pressed.connect(_on_fullscreen_toggled)
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	master_volume_slider.value_changed.connect(_on_volume_changed)
	mute_toggle.toggled.connect(_on_mute_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _update_resolution_dropdown_state():
	if fullscreen_toggle.button_pressed:
		# Get current screen resolution
		var screen_size = DisplayServer.screen_get_size()
		resolution_dropdown.disabled = true
		
		# Find and select the closest matching resolution
		var closest_index = 0
		var smallest_diff = Vector2.INF
		for i in range(ConfigManager.resolutions.size()):
			var diff = (ConfigManager.resolutions[i] - Vector2(screen_size)).length()
			if diff < smallest_diff.length():
				smallest_diff = Vector2(diff, diff)
				closest_index = i
		
		resolution_dropdown.selected = closest_index
		DisplayServer.window_set_size(screen_size)
	else:
		resolution_dropdown.disabled = false

func _on_fullscreen_toggled():
	print("Fullscreen toggled: ", fullscreen_toggle.button_pressed) # Debug print
	if fullscreen_toggle.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	_update_resolution_dropdown_state()
	save_settings()

func _on_resolution_selected(index: int):
	print("Resolution selected: ", index) # Debug print
	if index >= 0 and index < ConfigManager.resolutions.size() and not fullscreen_toggle.button_pressed:
		var resolution = ConfigManager.resolutions[index]
		DisplayServer.window_set_size(resolution)
		save_settings()

func _on_volume_changed(value: float):
	print("Volume changed: ", value) # Debug print
	AudioServer.set_bus_volume_db(0, value)
	save_settings()

func _on_mute_toggled(button_pressed: bool):
	print("Mute toggled: ", button_pressed) # Debug print
	AudioServer.set_bus_mute(0, button_pressed)
	save_settings()

func _on_back_pressed():
	print("Back pressed") # Debug print
	save_settings()
	options_closed.emit()
	queue_free()

func save_settings():
	ConfigManager.update_video_settings(
		fullscreen_toggle.button_pressed,
		resolution_dropdown.selected
	)
	ConfigManager.update_audio_settings(
		master_volume_slider.value,
		mute_toggle.button_pressed
	)

func load_settings():
	fullscreen_toggle.button_pressed = ConfigManager.config.video.fullscreen
	resolution_dropdown.selected = ConfigManager.config.video.resolution_index
	master_volume_slider.value = ConfigManager.config.audio.master_volume
	mute_toggle.button_pressed = ConfigManager.config.audio.muted
	
	# Apply the settings
	if ConfigManager.config.video.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_on_resolution_selected(ConfigManager.config.video.resolution_index)
	
	AudioServer.set_bus_volume_db(0, ConfigManager.config.audio.master_volume)
	AudioServer.set_bus_mute(0, ConfigManager.config.audio.muted)
