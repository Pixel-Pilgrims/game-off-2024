# decode_ui.gd
extends PanelContainer

signal aspect_selected(aspect: String)

@onready var decode_points_label = $MarginContainer/VBox/DecodePointsLabel
@onready var options_container = $MarginContainer/VBox/OptionsContainer

# Decode costs for each aspect
const COSTS = {
	"cost": 2,
	"type": 3,
	"value": 4,
	"description": 5
}

func _ready() -> void:
	hide()

func show_for_card(card: Node) -> void:
	# Clear previous options
	for child in options_container.get_children():
		child.queue_free()
	
	# Add new options based on card's decode state
	for aspect in COSTS:
		if not card.is_aspect_decoded(aspect):
			var button = Button.new()
			button.text = "Decode %s (%d points)" % [aspect.capitalize(), COSTS[aspect]]
			
			var decoder = get_node("/root/Main/Combat/DecoderManager")
			button.disabled = decoder.available_points < COSTS[aspect]
			
			button.pressed.connect(func(): 
				aspect_selected.emit(aspect)
				hide()
			)
			options_container.add_child(button)
	
	if options_container.get_child_count() == 0:
		var label = Label.new()
		label.text = "Card fully decoded!"
		options_container.add_child(label)
	
	# Show the popup
	show()
	# Center in viewport
	position = get_viewport_rect().size / 2 - size / 2
