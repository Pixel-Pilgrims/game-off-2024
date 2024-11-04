extends Node

const CONFIG_PATH = "user://config.cfg"

signal resolution_changed(new_resolution: Vector2)
signal window_mode_changed(is_fullscreen: bool)

var config = {
	"video": {
		"fullscreen": false,
		"resolution_index": 3  # Default to 1920x1080
	},
	"audio": {
		"master_volume": 0,
		"muted": false
	}
}

var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _ready() -> void:
	load_config()
	call_deferred("apply_config")

func save_config() -> void:
	var config_file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(config)
	config_file.store_string(json_string)

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		# Get current window state for initial config
		config.video.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		# Find closest resolution match for current window size
		var current_size = DisplayServer.window_get_size()
		var closest_index = 0
		var smallest_diff = Vector2.INF
		for i in range(resolutions.size()):
			var diff = (resolutions[i] - Vector2i(current_size)).length()
			if diff < smallest_diff.length():
				smallest_diff = Vector2(diff, diff)
				closest_index = i
		config.video.resolution_index = closest_index
		
		# Get current audio state
		config.audio.master_volume = AudioServer.get_bus_volume_db(0)
		config.audio.muted = AudioServer.is_bus_mute(0)
		
		save_config()
		return
		
	var config_file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_string = config_file.get_as_text()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var loaded_config = json.get_data()
		if typeof(loaded_config) == TYPE_DICTIONARY:
			if "video" in loaded_config:
				config.video = loaded_config.video
			if "audio" in loaded_config:
				config.audio = loaded_config.audio

func update_video_settings(fullscreen: bool, resolution_index: int) -> void:
	var mode_changed = config.video.fullscreen != fullscreen
	var res_changed = config.video.resolution_index != resolution_index
	
	config.video.fullscreen = fullscreen
	config.video.resolution_index = resolution_index
	apply_config()
	save_config()
	
	if mode_changed:
		window_mode_changed.emit(fullscreen)
	if res_changed:
		resolution_changed.emit(Vector2(resolutions[resolution_index]))

func apply_config() -> void:
	if config.video.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var resolution = resolutions[config.video.resolution_index]
		DisplayServer.window_set_size(resolution)
		
		# Center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - resolution) / 2
		DisplayServer.window_set_position(window_pos)
	
	# Apply audio settings
	AudioServer.set_bus_volume_db(0, config.audio.master_volume)
	AudioServer.set_bus_mute(0, config.audio.muted)

func update_audio_settings(volume: float, muted: bool) -> void:
	config.audio.master_volume = volume
	config.audio.muted = muted
	save_config()
