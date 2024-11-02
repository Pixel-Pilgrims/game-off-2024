extends Control

signal card_played(card)

var card_data: Resource

@onready var cost_label: Label = $MarginContainer/VBoxContainer/TopBar/CostLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/TopBar/NameLabel
@onready var effect_label: Label = $MarginContainer/VBoxContainer/EffectLabel

func setup(data: Resource) -> void:
	card_data = data
	update_display()

func update_display() -> void:
	await ready
	cost_label.text = str(card_data.energy_cost)
	name_label.text = card_data.name
	effect_label.text = card_data.effect_description

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
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
			enemy.take_damage(card_data.effect_value)
		"block":
			var player = get_node("/root/Main/Combat/Player")
			player.gain_block(card_data.effect_value)
