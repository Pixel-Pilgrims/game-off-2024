extends Node

var current_energy: int = 3
var max_energy: int = 3
var is_player_turn: bool = true

@onready var hand_manager: Node = $"../HandManager"
@onready var enemies_container: Node = $"../EnemiesContainer" 
@onready var energy_label: Label = $"../UI/HUD/EnergyMarginContainer/EnergyTexture/EnergyLabel"

func _ready() -> void:
	await hand_manager.ready
	start_turn()

func start_turn() -> void:
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
