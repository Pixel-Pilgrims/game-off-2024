# shop_card.gd
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

# Helper function to check if aspect is decoded
func is_aspect_decoded(aspect: String) -> bool:
	if not card_resource_path:
		return false
	var decoded = GameState.decoded_aspects.get(card_resource_path, {})
	return decoded.get(aspect, false)

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
	var aspects = ["cost", "type", "value", "description"]
	var id = 0
	
	for aspect in aspects:
		if not is_aspect_decoded(aspect):
			var cost = decoder_manager.DECODE_COSTS[aspect]
			popup.add_item("Decipher %s (%d points)" % [aspect.capitalize(), cost], id)
			popup.set_item_disabled(popup.item_count - 1, not decoder_manager.can_decode_aspect(aspect))
			id += 1
	
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
		
	var aspects = ["cost", "type", "value", "description"]
	if id >= 0 and id < aspects.size():
		var aspect = aspects[id]
		if decoder_manager.can_decode_aspect(aspect):
			decoder_manager.decode_aspect(self, aspect)
