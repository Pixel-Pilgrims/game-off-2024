# options_menu.gd
extends Control

signal options_closed

# Scene References
@onready var fullscreen_toggle = %FullscreenToggle
@onready var resolution_dropdown = %ResolutionOptionButton
@onready var master_volume_slider = %VolumeSlider
@onready var mute_toggle = %MuteToggle
@onready var back_button = %BackButton
@onready var volume_label = %VolumeLabelValue
@onready var skip_introduction_toggle = %SkipIntroToggle

# Constants for volume conversion
const MIN_DB = -80
const MAX_DB = 0

func _ready():
	setup_controls()
	load_settings()
	connect_signals()

func setup_controls():
	# Setup resolution dropdown
	for resolution in ConfigManager.resolutions:
		resolution_dropdown.add_item("%dx%d" % [resolution.x, resolution.y])
	
	# Setup volume slider with percentage values
	master_volume_slider.min_value = 0
	master_volume_slider.max_value = 100
	master_volume_slider.step = 1
	
	# Load initial values
	fullscreen_toggle.button_pressed = ConfigManager.config.video.fullscreen
	resolution_dropdown.selected = ConfigManager.config.video.resolution_index
	# Convert from dB to percentage for display
	master_volume_slider.value = db_to_percent(ConfigManager.config.audio.master_volume)
	mute_toggle.button_pressed = ConfigManager.config.audio.muted
		
	# Update volume display
	_update_volume_label(master_volume_slider.value)
	
	# Update resolution dropdown state based on fullscreen
	_update_resolution_dropdown_state()

func connect_signals():
	print("Connecting signals...") # Debug print
	fullscreen_toggle.pressed.connect(_on_fullscreen_toggled)
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	master_volume_slider.value_changed.connect(_on_volume_changed)
	mute_toggle.toggled.connect(_on_mute_toggled)
	back_button.pressed.connect(_on_back_pressed)
	skip_introduction_toggle.toggled.connect(_on_skip_introduction_toggled)

# Convert decibel value to percentage (0-100)
func db_to_percent(db: float) -> float:
	if db <= MIN_DB:
		return 0.0
	if db >= MAX_DB:
		return 100.0
	return ((db - MIN_DB) / (MAX_DB - MIN_DB)) * 100.0

# Convert percentage (0-100) to decibel value
func percent_to_db(percent: float) -> float:
	return lerp(MIN_DB, MAX_DB, percent / 100.0)

func _update_volume_label(percent: float) -> void:
	volume_label.text = "%d%%" % percent

func _on_volume_changed(value: float):
	print("Volume changed to ", value, "%")
	_update_volume_label(value)
	var db_value = percent_to_db(value)
	AudioServer.set_bus_volume_db(0, db_value)
	save_settings()

func _update_resolution_dropdown_state():
	if fullscreen_toggle.button_pressed:
		# Get current screen resolution
		var screen_size = DisplayServer.screen_get_size()
		resolution_dropdown.disabled = true
		
		# Find and select the closest matching resolution
		var closest_index = 0
		var smallest_diff = Vector2.INF
		for i in range(ConfigManager.resolutions.size()):
			var diff = (ConfigManager.resolutions[i] - screen_size).length()
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

func _on_mute_toggled(button_pressed: bool):
	print("Mute toggled: ", button_pressed) # Debug print
	AudioServer.set_bus_mute(0, button_pressed)
	save_settings()
	
func _on_skip_introduction_toggled(button_pressed: bool):
	print("Skip Intro toggled: ", button_pressed)
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
		percent_to_db(master_volume_slider.value),
		mute_toggle.button_pressed
	)
	ConfigManager.update_game_settings(
		skip_introduction_toggle.button_pressed
	)

func load_settings():
	fullscreen_toggle.button_pressed = ConfigManager.config.video.fullscreen
	resolution_dropdown.selected = ConfigManager.config.video.resolution_index
	master_volume_slider.value = db_to_percent(ConfigManager.config.audio.master_volume)
	_update_volume_label(master_volume_slider.value)
	mute_toggle.button_pressed = ConfigManager.config.audio.muted
	skip_introduction_toggle.button_pressed = ConfigManager.config.game.skip_intro
	
	# Apply the settings
	if ConfigManager.config.video.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_on_resolution_selected(ConfigManager.config.video.resolution_index)
	
	AudioServer.set_bus_volume_db(0, ConfigManager.config.audio.master_volume)
	AudioServer.set_bus_mute(0, ConfigManager.config.audio.muted)
