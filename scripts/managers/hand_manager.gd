extends Node
class_name HandManager

const CARD_SCENE = preload("res://scenes/card.tscn")

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []

@onready var hand_container = $"../UI/HUD/HandContainer"

func _ready() -> void:
	setup_starting_deck()

func setup_starting_deck() -> void:
	# Add basic cards
	for i in range(5):
		var attack_card = load("res://resources/cards/attack_card.tres")
		var block_card = load("res://resources/cards/block_card.tres")
		draw_pile.append(attack_card)
		draw_pile.append(block_card)
	draw_pile.shuffle()

func draw_cards(amount: int) -> void:
	print("Hand manager: drawing %d cards" % [amount])
	for i in range(amount):
		if draw_pile.size() == 0:
			print("Draw pile empty")
			reshuffle_discard()
			if draw_pile.size() == 0:
				return
		var card_data = draw_pile.pop_front()
		create_card(card_data)

func create_card(card_data: Resource) -> void:
	var card_instance = CARD_SCENE.instantiate()
	hand_container.add_child(card_instance)
	
	# Load decode state from GameState
	var decoded_aspects = {}
	if card_data.resource_path in GameState.decoded_aspects:
		decoded_aspects = GameState.decoded_aspects[card_data.resource_path].duplicate()
	
	# Initialize card with both data and decode state
	card_instance.setup(card_data, decoded_aspects)
	card_instance.connect("card_played", _on_card_played, CONNECT_ONE_SHOT)
	hand.append(card_instance)

func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card.card_data)
		card.queue_free()
	hand.clear()

func reshuffle_discard() -> void:
	print("Reshuffling discard")
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	draw_pile.shuffle()

func _on_card_played(card: Variant) -> void:
	hand.remove_at(hand.find(card))
	discard_pile.append(card.card_data)
	
func force_play_random_cards(amount: int) -> void:
	var cards_to_play = min(amount, hand.size())
	for i in range(cards_to_play):
		if hand.size() > 0:
			var random_index = randi() % hand.size()
			var card = hand[random_index]
			card.play_card()

func corrupt_random_cards(amount: int) -> void:
	var decoded_cards = []
	for card in hand:
		if card.has_decoded_aspects():
			decoded_cards.append(card)
	
	# Shuffle and corrupt up to 'amount' cards
	decoded_cards.shuffle()
	for i in range(min(amount, decoded_cards.size())):
		decoded_cards[i].corrupt_knowledge()
