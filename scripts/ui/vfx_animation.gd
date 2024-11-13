# vfx_animation.gd
extends Node2D

@export var sprite: Sprite2D
@export var frames: int = 1
@export var fps: int = 12
@export var offset: Vector2
@export var auto_free: bool = true

var frame_time: float
var current_frame: int = 0
var playing: bool = false

func _ready() -> void:
	frame_time = 1.0 / fps
	if sprite and sprite.texture:
		var frame_width = sprite.texture.get_width() / frames
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, frame_width, sprite.texture.get_height())
	position += offset

func _process(delta: float) -> void:
	if not playing:
		return
		
	frame_time -= delta
	if frame_time <= 0:
		frame_time = 1.0 / fps
		current_frame += 1
		
		if current_frame >= frames:
			if auto_free:
				queue_free()
			else:
				playing = false
				return
		
		if sprite and sprite.texture:
			var frame_width = sprite.texture.get_width() / frames
			sprite.region_rect.position.x = frame_width * current_frame

func play() -> void:
	playing = true
