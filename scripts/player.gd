extends Node2D

signal died
signal energy_changed(new_amount: int, max_amount: int)
signal damage_taken(amount: int)
signal block_gained(amount: int)

@onready var health_bar: HealthBar = $HealthBar
@onready var combat_animator: CombatAnimator = $CombatAnimator

@export var health: int = 100
@export var max_health: int = 100
@export var block: int = 0
@export var current_energy: int = 3
@export var max_energy: int = 3

func _ready() -> void:
	update_energy_display()
	health_bar.setup(max_health, true)

func take_damage(amount: int) -> void:
	SoundEffectsSystem.play_sound("combat", "damage_taken", -5.0)
	
	# First reduce block
	var initial_block = block
	var initial_health = health
	var remaining_damage = amount
	
	if block > 0:
		var blocked = min(block, amount)
		remaining_damage -= blocked
		block -= blocked
		if blocked > 0:
			await combat_animator.animate_block_change(initial_block, block, health_bar)
		CombatLogSystem.add("Player blocked {amount} damage.".format({"amount": blocked}))
	
	# Then reduce health
	if remaining_damage > 0:
		health -= remaining_damage
		await combat_animator.animate_health_change(initial_health, health, health_bar)
	
	damage_taken.emit(amount)
	
	if health <= 0:
		died.emit()

func gain_block(amount: int) -> void:
	SoundEffectsSystem.play_sound("combat", "block", -5.0)
	var initial_block = block
	block += amount
	await combat_animator.animate_block_change(initial_block, block, health_bar)
	block_gained.emit(amount)

func update_energy_display() -> void:
	energy_changed.emit(current_energy, max_energy)

func start_turn() -> void:
	current_energy = max_energy
	var initial_block = block
	block = 0
	if initial_block > 0:
		await combat_animator.animate_block_change(initial_block, 0, health_bar)
	update_energy_display()

func spend_energy(amount: int) -> void:
	current_energy = max(0, current_energy - amount)
	update_energy_display()

func can_spend_energy(amount: int) -> bool:
	return current_energy >= amount
