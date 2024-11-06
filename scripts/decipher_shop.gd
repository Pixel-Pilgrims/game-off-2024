extends Control

# First, move the shop card script to a constant reference
const ShopCardScript = preload("res://scripts/scenes/decipher_shop_card.gd")

@onready var grid_container = $ScrollShop/ScrollContainer/GridContainer
@onready var scroll_container = $ScrollShop/ScrollContainer
@onready var card_scene = preload("res://scenes/card.tscn")
@onready var points_label = $DecipherPointsLabel
@onready var decoder_manager = $DecoderManager

# Cards available for deciphering
var available_cards = GameState.current_deck

var card_size: Vector2

func _ready() -> void:
	setup_grid_container()
	populate_shop_cards()
	update_points_display()
	
	# Connect to decoder manager signals
	decoder_manager.points_changed.connect(_on_points_changed)
	decoder_manager.aspect_decoded.connect(_on_aspect_decoded)

func setup_grid_container() -> void:
	# Configure grid layout
	grid_container.columns = 3
	grid_container.add_theme_constant_override("h_separation", 20)
	grid_container.add_theme_constant_override("v_separation", 20)
	
	# Make GridContainer take full width
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	
	# Calculate card sizes based on scroll container width
	var available_width = scroll_container.size.x
	var card_width = (available_width - (grid_container.columns - 1) * grid_container.get_theme_constant("h_separation")) / grid_container.columns
	card_size = Vector2(card_width, card_width * 1.5)
	
	# Calculate total height needed
	var rows = ceil(float(available_cards.size()) / grid_container.columns)
	var total_height = (card_size.y * rows) + ((rows - 1) * grid_container.get_theme_constant("v_separation"))
	
	# Set GridContainer size
	grid_container.custom_minimum_size = Vector2(available_width, total_height)

func populate_shop_cards() -> void:
	# Clear existing cards
	for child in grid_container.get_children():
		child.queue_free()
	
	# Add available cards to the shop
	for card_path in available_cards:
		var card_resource = load(card_path)
		if card_resource:
			var card_instance = card_scene.instantiate()
		
			# Set the script before setup
			card_instance.set_script(ShopCardScript)
			
			grid_container.add_child(card_instance)
			
			# Set the card's custom minimum size
			card_instance.custom_minimum_size = card_size - Vector2(-10, -30)
			
			# Make the card expand to fill its cell
			card_instance.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			card_instance.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			# Get decoded aspects for this card from GameState
			var decoded_aspects = GameState.decoded_aspects.get(card_path, {})
			
			# Set up the card with both resource and decoder manager
			if card_instance.has_method("setup_shop_card"):
				card_instance.setup_shop_card(card_resource, decoded_aspects, decoder_manager)
			
func update_points_display() -> void:
	points_label.text = "Decipher Points: " + str(decoder_manager.available_points)

func _on_points_changed(new_amount: int) -> void:
	update_points_display()

func _on_aspect_decoded(_card_id: String, _aspect: String) -> void:
	# Refresh the cards to show updated decode status
	populate_shop_cards()
