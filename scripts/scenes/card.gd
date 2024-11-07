# card.gd
extends Control

signal card_played(card)

var card_data: Resource
var decoded_aspects: Dictionary = {}

@onready var sprite: Sprite2D = $Sprite2D
@onready var cost_label: Label = $MarginContainer/VBoxContainer/TopBar/CostLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/TopBar/NameLabel
@onready var effect_label: Label = $MarginContainer/VBoxContainer/EffectLabel

# Constants for unread display
const UNKNOWN_COST = "?"
const UNKNOWN_NAME = "???"
const UNKNOWN_EFFECT = "????????????"

func _ready():
	var material = ShaderMaterial.new()
	material.shader = preload("res://resources/shaders/card_glow.gdshader")
	sprite.material = material
	# Start with no glow
	set_selected(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Important: Enable mouse processing
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_selected(is_selected: bool):
	if not sprite.material:
		return
	sprite.material.set_shader_parameter("glow_strength", 1.0 if is_selected else 0.0)
	
func setup(data: Resource, starting_decoded_aspects: Dictionary = {}) -> void:
	card_data = data
	decoded_aspects = starting_decoded_aspects
	update_display()

func update_display() -> void:	
	if not is_node_ready():
		await ready
		
	await get_tree().process_frame
	 
	# Cost display
	if is_aspect_decoded("cost"):
		cost_label.text = str(card_data.energy_cost)
	else:
		cost_label.text = UNKNOWN_COST
	
	# Name display
	if is_aspect_decoded("name"):
		name_label.text = str(card_data.name)
	else:
		name_label.text = UNKNOWN_NAME
	
	# Effect display
	if is_aspect_decoded("description"):
		effect_label.text = str(card_data.effect_description)
	else:
		effect_label.text = UNKNOWN_EFFECT
		

func is_aspect_decoded(aspect: String) -> bool:
	return decoded_aspects.get(aspect, false)

func reveal_aspect(aspect: String) -> void:
	print("Revealing " + aspect)
	decoded_aspects[aspect] = true
	# Save to GameState
	if not card_data.resource_path in GameState.decoded_aspects:
		GameState.decoded_aspects[card_data.resource_path] = {}
	GameState.decoded_aspects[card_data.resource_path][aspect] = true
	update_display()

func get_effect_value() -> int:
	if is_aspect_decoded("value"):
		return card_data.effect_value
	else:
		# Random value for unread cards
		match card_data.card_type:
			"attack": return randi_range(4, 8)
			"block": return randi_range(4, 8)
			_: return card_data.effect_value

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			show_decode_menu()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var combat_manager = get_node("/root/Main/Combat/CombatManager")
			if combat_manager.can_play_card(card_data.energy_cost):
				play_card()

func play_card() -> void:
	var combat_manager = get_node("/root/Main/Combat/CombatManager")
	combat_manager.spend_energy(card_data.energy_cost)
	execute_effect()
	card_played.emit(self)
	queue_free()

func execute_effect() -> void:
	match card_data.card_type:
		"attack":
			var enemy = get_node("/root/Main/Combat/Enemy")
			enemy.take_damage(get_effect_value())
		"block":
			var player = get_node("/root/Main/Combat/Player")
			player.gain_block(get_effect_value())

func show_decode_menu() -> void:
	var popup = PopupMenu.new()
	add_child(popup)
		
	# Add decode options
	if not is_aspect_decoded("cost"):
		popup.add_item("Decode Cost (2 points)", 0)
	if not is_aspect_decoded("type"):
		popup.add_item("Decode Type (3 points)", 1)
	if not is_aspect_decoded("name"):
		popup.add_item("Decode name (4 points)", 2)
	if not is_aspect_decoded("description"):
		popup.add_item("Decode Description (5 points)", 3)
		
	if popup.item_count == 0:
		popup.add_item("Fully Decoded", -1)
		popup.set_item_disabled(0, true)
	
	popup.id_pressed.connect(_on_decode_option_selected)
	popup.position = get_global_mouse_position()
	popup.popup()
	
func _on_decode_option_selected(id: int) -> void:
	var decoder = $DecoderManager
	match id:
		0: decoder.decode_aspect(self, "cost")
		1: decoder.decode_aspect(self, "type")
		2: decoder.decode_aspect(self, "name")
		3: decoder.decode_aspect(self, "description")
		
func _on_mouse_entered():
	set_selected(true)

func _on_mouse_exited():
	set_selected(false)
