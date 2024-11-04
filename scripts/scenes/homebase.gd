# home_base.gd
extends Control

@onready var decipher_shop = $DecipherShop
@onready var player_stats = $PlayerStats
@onready var combat_button = $ButtonsContainer/StartCombatButton

func _ready() -> void:
	update_player_stats()
	setup_buttons()

func setup_buttons() -> void:
	$ButtonsContainer/StartCombatButton.pressed.connect(_on_start_combat_pressed)
	$ButtonsContainer/SaveQuitButton.pressed.connect(_on_save_quit_pressed)

func update_player_stats() -> void:
	var stats_text = "HP: %d/%d\nGold: %d\nDecipher Points: %d" % [
		GameState.current_hp,
		GameState.current_max_hp,
		GameState.current_gold,
		GameState.decode_points
	]
	player_stats.text = stats_text

func _on_start_combat_pressed() -> void:
	get_node("/root/Main").start_combat()

func _on_save_quit_pressed() -> void:
	GameState.save_game()
	# Return to main menu
	get_node("/root/Main").switch_to_main_menu()
