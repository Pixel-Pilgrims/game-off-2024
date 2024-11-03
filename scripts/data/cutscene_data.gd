class_name CutsceneData
extends Resource

@export var audio_track: AudioStream
@export var frames: Array[CutsceneFrameData]

func _init():
	frames = []
