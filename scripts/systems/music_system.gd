extends Node

func play_background_music(resource_path: String, volume: float = 1.0) -> void:
	print("Attempting to play: ", resource_path)
	for child in get_children():
		child.queue_free()
	
	var stream_player = AudioStreamPlayer.new()
	var audio_stream = load(resource_path)
	
	# Check if file loaded properly
	if !audio_stream:
		push_error("Could not load audio file: " + resource_path)
		return
		
	if !audio_stream is AudioStream:
		push_error("Resource is not an audio stream: " + resource_path)
		return
	
	stream_player.stream = audio_stream
	stream_player.volume_db = linear_to_db(volume)
	
	# Set loop mode based on stream type
	if audio_stream is AudioStreamWAV:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		audio_stream.loop_begin = 0
		audio_stream.loop_end = int(audio_stream.get_length() * audio_stream.mix_rate)
	elif audio_stream is AudioStreamOggVorbis:
		audio_stream.loop = true
	elif audio_stream is AudioStreamMP3:
		audio_stream.loop = true
	
	# Add to scene and play
	add_child(stream_player)
	stream_player.play()
	print("Started playback, playing: ", stream_player.playing)
