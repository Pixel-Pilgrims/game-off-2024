# scripts/player.gd
extends Node2D

signal died
signal energy_changed(new_amount: int, max_amount: int)
signal damage_taken(amount: int)
signal block_gained(amount: int)

@export var health: int = 40
@export var max_health: int = 40
@export var block: int = 0
@export var current_energy: int = 3
@export var max_energy: int = 3

@onready var health_label = $HealthLabel

func _ready() -> void:
	update_health_display()
	update_energy_display()

func take_damage(amount: int) -> void:
	# First reduce block
	if block > 0:
		var blocked = min(block, amount)
		amount -= blocked
		block -= blocked
	
	# Then reduce health
	if amount > 0:
		health -= amount
		print("Player took ", amount, " damage. Health: ", health)
	
	damage_taken.emit(amount)    
	update_health_display()
	
	if health <= 0:
		died.emit()

func gain_block(amount: int) -> void:
	block += amount
	block_gained.emit(amount)
	update_health_display()

func update_health_display() -> void:
	var block_text = " [" + str(block) + "]" if block > 0 else ""
	health_label.text = str(health) + "/" + str(max_health) + block_text

func update_energy_display() -> void:
	energy_changed.emit(current_energy, max_energy)

func start_turn() -> void:
	current_energy = max_energy
	update_energy_display()

func spend_energy(amount: int) -> void:
	current_energy = max(0, current_energy - amount)
	update_energy_display()

func can_spend_energy(amount: int) -> bool:
	return current_energy >= amount
