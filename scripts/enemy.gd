extends Node2D

signal died
signal damage_taken(amount: int)
signal turn_ended
signal intent_changed(intent: AbilityData)
signal attack_executed(damage: int, target: Node)
signal block_gained(amount: int)

@onready var health_bar: HealthBar = $HealthBar
@onready var combat_animator: CombatAnimator = $CombatAnimator
@onready var intent_indicator: IntentDisplay = $IntentDisplay

var health: int = 30
var max_health: int = 30
var abilities: Array[AbilityData] = []
var current_intent: AbilityData
var block: int = 0
var is_executing_turn := false
var strength: int = 0
var decode_sealed: bool = false
var decode_seal_duration: int = 0
var decoded_card_resistance: float = 0.0

# Add these methods to handle the new effects
func modify_strength(amount: int) -> void:
	strength += amount
	# Optional: Create a strength indicator in the UI
	
func seal_decoding(duration: int) -> void:
	decode_sealed = true
	decode_seal_duration = duration
	# Signal to UI/game systems that decoding is sealed
	
func force_play_cards(amount: int) -> void:
	# Get reference to hand manager
	var hand_manager = get_node("/root/Main/Combat/HandManager")
	if hand_manager:
		hand_manager.force_play_random_cards(amount)
		
func corrupt_card_knowledge(amount: int) -> void:
	# Get random decoded cards and scramble their knowledge
	var hand_manager = get_node("/root/Main/Combat/HandManager")
	if hand_manager:
		hand_manager.corrupt_random_cards(amount)
		
func set_decoded_card_resistance(value: float) -> void:
	decoded_card_resistance = value / 100.0  # Convert from percentage

func take_damage(amount: int, from_decoded: bool = false) -> void:
	# Calculate final damage amount
	var final_amount = amount
	
	# Apply decoded card resistance if applicable
	if from_decoded and decoded_card_resistance > 0:
		final_amount = int(amount * (1.0 - decoded_card_resistance))
	
	# Apply strength modifier (negative strength reduces damage taken)
	if strength != 0:
		final_amount = max(0, final_amount + strength)
	
	# Apply the damage using the original logic
	var initial_health = health
	health -= final_amount
	
	SoundEffectsSystem.play_sound("combat", "damage_taken", -5.0)
	
	# Animate the health change
	if combat_animator:
		combat_animator.animate_health_change(initial_health, health, health_bar)
	
	damage_taken.emit(final_amount)
	print("Enemy took ", final_amount, " damage (original: ", amount, ")")
	
	if health <= 0:
		print("Enemy died")
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
	
func end_turn() -> void:
	if decode_seal_duration > 0:
		decode_seal_duration -= 1
		if decode_seal_duration <= 0:
			decode_sealed = false
	
	# Reset per-turn effects
	decoded_card_resistance = 0.0
	
	emit_signal("turn_ended")

func execute_intent() -> void:
	if not current_intent:
		return
	print("Enemy uses ", current_intent.name)
	
	var target = get_node_or_null("/root/Main/Combat/Player")
	if not target:
		push_warning("No player found for enemy intent")
		return

	# If ability needs an attack animation
	var needs_attack_animation = false
	for effect in current_intent.effects:
		if effect.parameters.has("min_damage") or effect.parameters.has("max_damage"):
			needs_attack_animation = true
			break
	
	if needs_attack_animation and target:
		await combat_animator.animate_attack(target)

	# Execute all effects
	for effect in current_intent.effects:
		# REMOVE THIS PART - Don't emit redundant signals
		# if effect.parameters.has("min_damage") and effect.parameters.has("max_damage"):
		#     var damage = randi_range(effect.parameters.min_damage, effect.parameters.max_damage)
		#     attack_executed.emit(damage, self)
			
		# Just execute the effect
		effect.execute(self, target)
		
		if effect != current_intent.effects.back():
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
	intent_indicator.display_intent(current_intent)
	intent_changed.emit(current_intent)

func setup(enemy_data: EnemyData) -> void:
	if not is_node_ready():
		await ready
	health = enemy_data.health
	max_health = enemy_data.health
	abilities = enemy_data.abilities
	health_bar.setup(max_health, false)
	set_next_intent()
