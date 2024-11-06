# decoder_manager.gd
extends Node

signal aspect_decoded(card_id: String, aspect: String)
signal points_changed(new_amount: int)

var available_points: int = 30  # Start with some points for testing

const DECODE_COSTS = {
	"cost": 2,
	"type": 3,
	"name": 4,
	"description": 5
}

func _ready() -> void:
	# Update UI on startup
	points_changed.emit(available_points)

func can_decode_aspect(aspect: String) -> bool:
	if not DECODE_COSTS.has(aspect):
		return false
	return available_points >= DECODE_COSTS[aspect]

func decode_aspect(card: Node, aspect: String) -> void:
	if not can_decode_aspect(aspect):
		return
		
	var cost = DECODE_COSTS[aspect]
	available_points -= cost
	points_changed.emit(available_points)
	
	# Get card_id from the resource_path or card_path property
	var card_id: String
	if card.has_method("get_card_path"):
		card_id = card.get_card_path()
	else:
		push_error("Card node doesn't have required get_card_path method")
		return
	
	# Store the decoded information
	if not GameState.decoded_aspects.has(card_id):
		GameState.decoded_aspects[card_id] = {}
	GameState.decoded_aspects[card_id][aspect] = true
	
	# Update card display
	card.reveal_aspect(aspect)
	aspect_decoded.emit(card_id, aspect)
	
	# Update decode UI if it's visible
	var decode_ui = get_node_or_null("/root/Main/Combat/UI/DecodeUI")
	if decode_ui and decode_ui.visible and decode_ui.has_method("update_points"):
		decode_ui.update_points()

func add_points(amount: int) -> void:
	available_points += amount
	points_changed.emit(available_points)
	GameState.save_game()
