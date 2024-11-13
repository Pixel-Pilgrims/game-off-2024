extends Node2D

signal died
signal damage_taken(amount: int)
signal turn_ended
signal intent_changed(intent: AbilityData)
signal attack_executed(damage: int, target: Node)
signal block_gained(amount: int)

@onready var health_bar: HealthBar = $HealthBar
@onready var combat_animator: CombatAnimator = $CombatAnimator

var health: int = 30
var max_health: int = 30
var abilities: Array[AbilityData] = []
var current_intent: AbilityData
var block: int = 0
var is_executing_turn := false

func take_damage(amount: int) -> void:
	var initial_health = health
	health -= amount
	
	SoundEffectsSystem.play_sound("combat", "damage_taken", -5.0)
	await combat_animator.animate_health_change(initial_health, health, health_bar)
	damage_taken.emit(amount)

	CombatLogSystem.add("Enemy took  {amount} damage".format({"amount": amount}))
	if health <= 0:
		CombatLogSystem.add("Enemy died")
		died.emit()
		queue_free()

func take_turn() -> void:
	if is_executing_turn:
		push_error("Enemy is already executing a turn")
		return
		
	is_executing_turn = true
	
	if current_intent:
		await execute_intent()
		
	# Add a small delay between intent execution and turn end
	await get_tree().create_timer(0.2).timeout
	
	set_next_intent()
	is_executing_turn = false
	turn_ended.emit()

func execute_intent() -> void:
	CombatLogSystem.add("Enemy uses {intent}".format({"intent": current_intent.name}))
	match current_intent.type:
		AbilityData.AbilityType.ATTACK:
			# Find player node
			var player = get_node("/root/Main/Combat/Player")
			if player:
				# Start attack animation
				await combat_animator.animate_attack(player)
				# Execute attack
				attack_executed.emit(current_intent.value, self)
				# Wait for a moment after attack
				await get_tree().create_timer(0.2).timeout
				
		AbilityData.AbilityType.BLOCK:
			var initial_block = block
			block += current_intent.value
			await combat_animator.animate_block_change(initial_block, block, health_bar)
			block_gained.emit(current_intent.value)
			await get_tree().create_timer(0.2).timeout

func gain_block(amount: int) -> void:
	var initial_block = block
	block += amount
	combat_animator.animate_block_change(initial_block, block, health_bar)
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
