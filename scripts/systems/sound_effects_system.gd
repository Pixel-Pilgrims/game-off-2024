extends Node

# Preloaded sound effect dictionaries
var combat_sfx = {
	"attack": [
		preload("res://assets/audio/sfx/28_swoosh_01.wav"),
		preload("res://assets/audio/sfx/29_swoosh_02.wav"),
		preload("res://assets/audio/sfx/30_swoosh_03.wav")
	],
	"block": [
		preload("res://assets/audio/sfx/37_Block_01.wav"),
		preload("res://assets/audio/sfx/40_Block_04.wav")
	],
	"damage_taken": [
		preload("res://assets/audio/sfx/03_Fighter_Damage_1.wav"),
		preload("res://assets/audio/sfx/04_Fighter_Damage_2.wav")
	]
}

var ui_sfx = {
	"button_hover": [
		preload("res://assets/audio/ui/007_Hover_07.wav"),
	],
	"button_click": [
		preload("res://assets/audio/ui/Click_1.wav"),
	],
	"card_hover": [
		preload("res://assets/audio/ui/Hover_1.wav"),
	],
	"card_play": [
		preload("res://assets/audio/ui/052_use_item_02.wav"),
	],
}

# Pool of audio players for sound effects
var audio_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

func _ready() -> void:
	# Initialize pool of audio players
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "SoundEffects"  # Make sure to create this bus in the project settings
		add_child(player)
		audio_players.append(player)

func play_sound(category: String, type: String, volume_db: float = 0.0) -> void:
	var sounds = []
	match category:
		"combat":
			sounds = combat_sfx.get(type, [])
		"ui":
			sounds = ui_sfx.get(type, [])
	
	if sounds.is_empty():
		return
		
	# Get random sound from array
	var sound = sounds[randi() % sounds.size()]
	
	# Find available player
	for player in audio_players:
		if not player.playing:
			player.stream = sound
			player.volume_db = volume_db
			player.play()
			return
	
	# If no player is available, stop oldest and reuse
	audio_players[0].stop()
	audio_players[0].stream = sound
	audio_players[0].volume_db = volume_db
	audio_players[0].play()
	
	# Move used player to end of array
	var player = audio_players.pop_front()
	audio_players.push_back(player)
