# scripts/scenes/card.gd
extends Control

signal card_played(card: Node)
signal effect_executed(effect_type: String, value: int, target: Node)

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

func _ready() -> void:
	# Set fixed size for cards
	custom_minimum_size = Vector2(200, 300)
	size = Vector2(200, 300)
	
	# Center card contents
	$MarginContainer.anchor_right = 1.0
	$MarginContainer.anchor_bottom = 1.0
	$MarginContainer.offset_right = 0
	$MarginContainer.offset_bottom = 0
	
	# Setup shader
	var material = ShaderMaterial.new()
	material.shader = preload("res://resources/shaders/card_glow.gdshader")
	sprite.material = material
	# Start with no glow
	set_selected(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Important: Enable mouse processing
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Update card display
	update_display()

func update_display() -> void:    
	if not is_node_ready():
		await ready
	# Cost display
	if is_aspect_decoded("cost"):
		cost_label.text = str(card_data.energy_cost)
	else:
		cost_label.text = UNKNOWN_COST
	
	# Name display
	if is_aspect_decoded("name"):
		name_label.text = card_data.name
	else:
		name_label.text = UNKNOWN_NAME
	
	# Effect display
	if is_aspect_decoded("description"):
		effect_label.text = card_data.effect_description
	else:
		effect_label.text = UNKNOWN_EFFECT

func is_aspect_decoded(aspect: String) -> bool:
	return decoded_aspects.get(aspect, false)
	
func setup(data: Resource, starting_decoded_aspects: Dictionary = {}) -> void:
	card_data = data
	decoded_aspects = starting_decoded_aspects

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
			var combat_scene = get_node("/root/Main/Combat")
			var player = combat_scene.get_node("Player")
			if player and player.can_spend_energy(card_data.energy_cost):
				play_card()

func play_card() -> void:
	var combat_scene = get_node("/root/Main/Combat")
	var player = combat_scene.get_node("Player")
	
	if player.can_spend_energy(card_data.energy_cost):
		player.spend_energy(card_data.energy_cost)
		execute_effect()
		card_played.emit(self)
		queue_free()

func execute_effect() -> void:
	var combat_scene = get_node("/root/Main/Combat")
	var effect_value = get_effect_value()
	
	match card_data.card_type:
		"attack":
			var enemies_container = combat_scene.get_node("EnemiesContainer")
			if enemies_container and enemies_container.get_child_count() > 0:
				var enemy = enemies_container.get_child(0)
				enemy.take_damage(effect_value)
				effect_executed.emit("attack", effect_value, enemy)
		"block":
			var player = combat_scene.get_node("Player")
			if player:
				player.gain_block(effect_value)
				effect_executed.emit("block", effect_value, player)

func show_decode_menu() -> void:
	var popup = PopupMenu.new()
	add_child(popup)
		
	# Add decode options
	if not is_aspect_decoded("cost"):
		popup.add_item("Decode Cost (2 points)", 0)
	if not is_aspect_decoded("type"):
		popup.add_item("Decode Type (3 points)", 1)
	if not is_aspect_decoded("value"):
		popup.add_item("Decode Value (4 points)", 2)
	if not is_aspect_decoded("description"):
		popup.add_item("Decode Description (5 points)", 3)
		
	if popup.item_count == 0:
		popup.add_item("Fully Decoded", -1)
		popup.set_item_disabled(0, true)
	
	popup.id_pressed.connect(_on_decode_option_selected)
	popup.position = get_global_mouse_position()
	popup.popup()
	
func _on_decode_option_selected(id: int) -> void:
	var combat_scene = get_node("/root/Main/Combat")
	var decoder = combat_scene.get_node("DecoderManager")
	match id:
		0: decoder.decode_aspect(self, "cost")
		1: decoder.decode_aspect(self, "type")
		2: decoder.decode_aspect(self, "value")
		3: decoder.decode_aspect(self, "description")

func set_selected(is_selected: bool):
	if not sprite.material:
		return
	sprite.material.set_shader_parameter("glow_strength", 1.0 if is_selected else 0.0)

func _on_mouse_entered():
	set_selected(true)

func _on_mouse_exited():
	set_selected(false)
