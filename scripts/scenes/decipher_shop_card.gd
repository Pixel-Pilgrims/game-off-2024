extends "res://scripts/scenes/card.gd"

var decoder_manager: Node = null
var card_resource_path: String = ""

func setup_shop_card(card_res: Resource, shop_decoded_aspects: Dictionary, decoder_ref: Node) -> void:
	decoder_manager = decoder_ref
	setup(card_res, shop_decoded_aspects)
	card_resource_path = card_res.resource_path

func get_card_path() -> String:
	return card_resource_path

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
	if not decoder_manager:
		push_error("Decoder manager not initialized")
		return
		
	var popup = PopupMenu.new()
	add_child(popup)

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
	
	if not is_aspect_decoded("name"):
		var cost = decoder_manager.DECODE_COSTS["name"]
		popup.add_item("Decipher name (%d points)" % cost, 2)
		popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect("name"))
	
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
	if not decoder_manager:
		push_error("Decoder manager not initialized")
		return
		
	var aspect_map = {
		0: "cost",
		1: "type",
		2: "name",
		3: "description"
	}
	
	if aspect_map.has(id):
		var aspect = aspect_map[id]
		if decoder_manager.can_decode_aspect(aspect):
			decoder_manager.decode_aspect(self, aspect)
