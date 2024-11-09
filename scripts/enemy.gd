# scripts/enemy.gd
extends Node2D

signal died
signal damage_taken(amount: int)
signal turn_ended
signal intent_changed(intent: AbilityData)
signal attack_executed(damage: int, target: Node)
signal block_gained(amount: int)

var health: int = 30
var max_health: int = 30
var abilities: Array[AbilityData] = []
var current_intent: AbilityData
var block: int = 0

@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	update_health_display()
	if not abilities.is_empty():
		set_next_intent()

func take_damage(amount: int) -> void:
	health -= amount
	damage_taken.emit(amount)
	update_health_display()
	if health <= 0:
		died.emit()
		queue_free()

func take_turn() -> void:
	if current_intent:
		execute_intent()
	set_next_intent()
	turn_ended.emit()

func execute_intent() -> void:
	match current_intent.type:
		AbilityData.AbilityType.ATTACK:
			attack_executed.emit(current_intent.value, self)
		AbilityData.AbilityType.BLOCK:
			gain_block(current_intent.value)
		# Add other ability types as needed

func gain_block(amount: int) -> void:
	block += amount
	block_gained.emit(amount)
	update_health_display()

func select_random_ability() -> AbilityData:
	if abilities.is_empty():
		return null
	
	var weighted_abilities: Array[AbilityData] = []
	for ability in abilities:
		for i in range(ability.weight):
			weighted_abilities.append(ability)
	
	return weighted_abilities[randi() % weighted_abilities.size()]

func set_next_intent() -> void:
	current_intent = select_random_ability()
	intent_changed.emit(current_intent)

func update_health_display() -> void:
	var block_text = " [" + str(block) + "]" if block > 0 else ""
	health_label.text = str(health) + "/" + str(max_health) + block_text

func setup(enemy_data: EnemyData) -> void:
	if not is_node_ready():
		await ready
	health = enemy_data.health
	max_health = enemy_data.health
	abilities = enemy_data.abilities
	update_health_display()
	set_next_intent()
