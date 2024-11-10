# scripts/enemy.gd
extends Node2D

signal died
signal damage_taken(amount: int)
signal turn_ended
signal intent_changed(intent: AbilityData)
signal attack_executed(damage: int, target: Node)
signal block_gained(amount: int)

@onready var health_bar: HealthBar = $HealthBar

var health: int = 30
var max_health: int = 30
var abilities: Array[AbilityData] = []
var current_intent: AbilityData
var block: int = 0

func take_damage(amount: int) -> void:
	health -= amount
	health_bar.set_health(health)
	damage_taken.emit(amount)
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
	health_bar.set_block(block)
	block_gained.emit(amount)

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

func setup(enemy_data: EnemyData) -> void:
	if not is_node_ready():
		await ready
	health = enemy_data.health
	max_health = enemy_data.health
	abilities = enemy_data.abilities
	health_bar.setup(max_health, false)
	set_next_intent()
