class_name CutsceneScene
extends Control

signal cutscene_finished

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var image_display: TextureRect = $TextureRect

var current_cutscene: CutsceneData
var current_frame_index: int = 0
var exit_callback: Callable

func _ready() -> void:
	audio_player.connect("finished", _on_audio_finished)

func start_cutscene(cutscene: CutsceneData, callback: Callable) -> void:
	if not cutscene:
		push_error("Invalid cutscene resource")
		return
		
	print("Cutscene: " + cutscene.resource_name)
	
	current_cutscene = cutscene
	current_frame_index = 0
	exit_callback = callback
	
	# Setup audio
	audio_player.stream = cutscene.audio_track
	audio_player.play()
	
	# Show first frame
	if cutscene.frames.size() > 0:
		image_display.texture = cutscene.frames[0].image
	
	# Start checking timestamps
	set_process(true)
	
	if ConfigManager.config.game.skip_intro:
		skip_cutscene()

func _process(_delta: float) -> void:
	if not current_cutscene or current_frame_index >= current_cutscene.frames.size():
		return
	
	var current_time = audio_player.get_playback_position()
	var next_frame = current_cutscene.frames[current_frame_index]
	
	if current_time >= next_frame.timestamp:
		image_display.texture = next_frame.image
		current_frame_index += 1

func _on_audio_finished() -> void:
	set_process(false)
	emit_signal("cutscene_finished")
	
	if exit_callback != null:
		exit_callback.call()
		
	self.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		skip_cutscene()

func skip_cutscene() -> void:
	audio_player.stop()
	_on_audio_finished()
