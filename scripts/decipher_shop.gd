# decipher_shop.gd
extends Control

@onready var grid_container = $ScrollShop/ScrollContainer/GridContainer
@onready var card_scene = preload("res://scenes/card.tscn")
@onready var points_label = $DecipherPointsLabel
@onready var decoder_manager = get_node("/root/Main/DecoderManager")

# Cards available for deciphering
var available_cards = [
	"res://resources/cards/attack_card.tres",
	"res://resources/cards/block_card.tres",
	# Add initial cards available in shop
]

func _ready() -> void:
	setup_grid_container()
	populate_shop_cards()
	update_points_display()
	
	# Connect to decoder manager signals
	decoder_manager.points_changed.connect(_on_points_changed)
	decoder_manager.aspect_decoded.connect(_on_aspect_decoded)

func setup_grid_container() -> void:
	grid_container.columns = 3
	grid_container.add_theme_constant_override("h_separation", 10)
	grid_container.add_theme_constant_override("v_separation", 10)

func populate_shop_cards() -> void:
	# Clear existing cards
	for child in grid_container.get_children():
		child.queue_free()
	
	# Add available cards to the shop
	for card_path in available_cards:
		var card_resource = load(card_path)
		if card_resource:
			var card_instance = card_scene.instantiate()
			grid_container.add_child(card_instance)
			
			# Get decoded aspects for this card from GameState
			var decoded_aspects = GameState.decoded_aspects.get(card_path, {})
			
			# Setup the card with its resource and decoded aspects
			card_instance.setup(card_resource, decoded_aspects)
			
			# Override the card script for shop functionality
			card_instance.set_script(DecipherShopCardScript)

func update_points_display() -> void:
	points_label.text = "Decipher Points: " + str(decoder_manager.available_points)

func _on_points_changed(new_amount: int) -> void:
	update_points_display()

func _on_aspect_decoded(_card_id: String, _aspect: String) -> void:
	# Refresh the cards to show updated decode status
	populate_shop_cards()

# Extended card script for shop cards
class DecipherShopCardScript extends "res://scripts/scenes/card.gd":
	# Override _gui_input to only handle decoding
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				show_decode_menu()
	
	# Override play_card to do nothing
	func play_card() -> void:
		pass
	
	# Override execute_effect to do nothing
	func execute_effect() -> void:
		pass
	
	# Modified show_decode_menu for shop context
	func show_decode_menu() -> void:
		var popup = PopupMenu.new()
		add_child(popup)
		
		var decoder_manager = get_node("/root/Main/DecoderManager")
		var points_available = decoder_manager.available_points
		
		popup.add_item("Available Points: " + str(points_available))
		popup.set_item_disabled(0, true)
		popup.add_separator()
		
		# Add available decipher options
		if not is_aspect_decoded("cost"):
			var cost = decoder_manager.DECODE_COSTS["cost"]
			popup.add_item("Decipher Cost (%d points)" % cost, 0)
			popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect("cost"))
		
		if not is_aspect_decoded("type"):
			var cost = decoder_manager.DECODE_COSTS["type"]
			popup.add_item("Decipher Type (%d points)" % cost, 1)
			popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect("type"))
		
		if not is_aspect_decoded("value"):
			var cost = decoder_manager.DECODE_COSTS["value"]
			popup.add_item("Decipher Value (%d points)" % cost, 2)
			popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect("value"))
		
		if not is_aspect_decoded("description"):
			var cost = decoder_manager.DECODE_COSTS["description"]
			popup.add_item("Decipher Description (%d points)" % cost, 3)
			popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect("description"))
		
		if popup.item_count == 2: # Only the points display and separator
			popup.add_item("Fully Deciphered", -1)
			popup.set_item_disabled(popup.item_count - 1, true)
		
		popup.id_pressed.connect(_on_decode_option_selected)
		popup.position = get_global_mouse_position()
		popup.popup()
	
	# Modified decode option handling to use decoder_manager
	func _on_decode_option_selected(id: int) -> void:
		var decoder_manager = get_node("/root/Main/DecoderManager")
		var aspect_map = {
			0: "cost",
			1: "type",
			2: "value",
			3: "description"
		}
		
		if aspect_map.has(id):
			var aspect = aspect_map[id]
			if decoder_manager.can_decode_aspect(aspect):
				decoder_manager.decode_aspect(self, aspect)
