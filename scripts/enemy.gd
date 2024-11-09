# enemy.gd
extends Node

signal attack_intent_changed(intent: AbilityData)

var health: int = 30
var max_health: int = 30
var abilities: Array[AbilityData] = []

@onready var health_label: Label = $HealthLabel
@onready var player = get_node("/root/Main/Combat/Player")

# Intent system
var current_intent: AbilityData

func _ready() -> void:
	update_health_display()
	# Set initial intent if we have abilities
	if not abilities.is_empty():
		set_next_intent()

func take_damage(amount: int) -> void:
	health -= amount
	update_health_display()
	if health <= 0:
		queue_free()

func take_turn() -> void:
	if not player:
		player = get_node("/root/Main/Combat/Player")
	
	if player and current_intent:
		current_intent.execute(self, player)
		print("Enemy uses ", current_intent.name)
	
	# Set intent for next turn
	set_next_intent()

func select_random_ability() -> AbilityData:
	if abilities.is_empty():
		return null
	
	# Create weighted list based on weight property
	var weighted_abilities: Array[AbilityData] = []
	for ability in abilities:
		for i in range(ability.weight):
			weighted_abilities.append(ability)
	
	# Select random ability from weighted list
	return weighted_abilities[randi() % weighted_abilities.size()]

func set_next_intent() -> void:
	current_intent = select_random_ability()
	emit_signal("attack_intent_changed", current_intent)

func update_health_display() -> void:
	health_label.text = str(health) + "/" + str(max_health)

func setup(enemy_data: EnemyData) -> void:
	if not is_node_ready():
		await ready
	health = enemy_data.health
	max_health = enemy_data.health
	abilities = enemy_data.abilities
	update_health_display()
	set_next_intent()  # Set initial intent after setup
