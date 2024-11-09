extends Node

const GAME_OVER_SCENE = preload("res://scenes/game_over.tscn")

var current_energy: int = 3
var max_energy: int = 3
var is_player_turn: bool = true
var turn_count: int = 0

@onready var hand_manager: HandManager = $"../HandManager"
@onready var enemies_container: Node = $"../EnemiesContainer" 
@onready var energy_label: Label = $"../UI/HUD/EnergyMarginContainer/EnergyTexture/EnergyLabel"

func _ready() -> void:
	# Connect to player death
	$"../Player".connect("died", _on_player_died)
	await hand_manager.ready
	start_turn()

func start_turn() -> void:
	turn_count += 1
	print("Start")
	current_energy = max_energy
	energy_label.text = str(current_energy)
	
	hand_manager.draw_cards(5)
	is_player_turn = true
	print("Player turn")

func end_turn() -> void:
	hand_manager.discard_hand()
	is_player_turn = false

	# Enemy turns
	for enemy in enemies_container.get_children():
		if enemy.has_method("take_turn"):
			enemy.take_turn()

	# Back to player
	start_turn()

func can_play_card(card_cost: int) -> bool:
	return is_player_turn and current_energy >= card_cost

func spend_energy(amount: int) -> void:
	current_energy -= amount
	energy_label.text = str(current_energy)
	
func _on_player_died() -> void:
	# Save meta progression
	GameState.end_run(false)
	
	var game_over = GAME_OVER_SCENE.instantiate()
	get_node("/root/Main").add_child(game_over)
	
	# Update stats display
	var stats_label = game_over.get_node("CenterContainer/VBoxContainer/StatsLabel")
	stats_label.text = "Rooms cleared: %d" % GameState.current_run
	
	# Connect continue signal
	game_over.continue_pressed.connect(_on_game_over_continue)
	game_over.open()
	
	# Pause the game
	get_tree().paused = true

func _on_game_over_continue() -> void:
	# Unpause
	get_tree().paused = false
	# Remove game over screen
	get_node("/root/Main").get_node("GameOver").queue_free()
	# Return to main menu
	get_node("/root/Main").show_main_menu()
