# game_state.gd
extends Node

# Persistent game progress
var total_runs: int = 0
var current_run: int = 0

# Card knowledge system
var decoded_aspects: Dictionary = {
	# Structure:
	# "res://resources/cards/attack_card.tres": {
	#    "cost": true,
	#    "type": true,
	#    "value": false,
	#    "description": false
	# }
}

# Current run state
var current_deck: Array = []
var current_gold: int = 100
var current_hp: int = 40
var current_max_hp: int = 40
var decode_points: int = 0

# Save data structure
const SAVE_PATH = "user://gamestate.save"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var save_data = {
		"meta_progress": {
			"total_runs": total_runs,
			"decoded_aspects": decoded_aspects,
		},
		"current_run": {
			"run_number": current_run,
			"current_deck": current_deck,
			"current_gold": current_gold,
			"current_hp": current_hp,
			"current_max_hp": current_max_hp,
			"decode_points": decode_points
		}
	}
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_string(json_string)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = save_file.get_as_text()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var save_data = json.get_data()
		
		# Load meta progress
		if "meta_progress" in save_data:
			total_runs = save_data["meta_progress"].get("total_runs", 0)
			decoded_aspects = save_data["meta_progress"].get("decoded_aspects", {})
		
		# Load current run
		if "current_run" in save_data:
			current_run = save_data["current_run"].get("run_number", 0)
			current_deck = save_data["current_run"].get("current_deck", [])
			current_gold = save_data["current_run"].get("current_gold", 100)
			current_hp = save_data["current_run"].get("current_hp", 40)
			current_max_hp = save_data["current_run"].get("current_max_hp", 40)
			decode_points = save_data["current_run"].get("decode_points", 0)

# Run management
func start_new_run() -> void:
	current_run = total_runs + 1
	current_gold = 100
	current_hp = 40
	current_max_hp = 40
	decode_points = 0
	current_deck.clear()
	setup_starting_deck()
	save_game()

func end_run(victory: bool) -> void:
	if victory:
		total_runs += 1
	save_game()

# Card knowledge management
func is_aspect_decoded(card_path: String, aspect: String) -> bool:
	if not decoded_aspects.has(card_path):
		return false
	return decoded_aspects[card_path].get(aspect, false)

func decode_aspect(card_path: String, aspect: String) -> void:
	if not decoded_aspects.has(card_path):
		decoded_aspects[card_path] = {}
	decoded_aspects[card_path][aspect] = true
	save_game()

func is_card_fully_decoded(card_path: String) -> bool:
	if not decoded_aspects.has(card_path):
		return false
	var aspects = decoded_aspects[card_path]
	return aspects.get("cost", false) and \
		   aspects.get("type", false) and \
		   aspects.get("value", false) and \
		   aspects.get("description", false)

# Deck management
func setup_starting_deck() -> void:
	# Load starting cards
	for i in range(5):
		current_deck.append("res://resources/cards/attack_card.tres")
		current_deck.append("res://resources/cards/block_card.tres")

# Resource management
func add_decode_points(amount: int) -> void:
	decode_points += amount
	save_game()

func spend_decode_points(amount: int) -> bool:
	if decode_points >= amount:
		decode_points -= amount
		save_game()
		return true
	return false

func add_gold(amount: int) -> void:
	current_gold += amount
	save_game()

func spend_gold(amount: int) -> bool:
	if current_gold >= amount:
		current_gold -= amount
		save_game()
		return true
	return false

# Health management
func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, current_max_hp)
	save_game()

func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	save_game()

func increase_max_hp(amount: int) -> void:
	current_max_hp += amount
	current_hp += amount
	save_game()
