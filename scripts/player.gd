# scripts/player.gd
extends Node2D

signal died
signal energy_changed(new_amount: int, max_amount: int)
signal damage_taken(amount: int)
signal block_gained(amount: int)

@onready var health_bar: HealthBar = $HealthBar

@export var health: int = 100
@export var max_health: int = 100
@export var block: int = 0
@export var current_energy: int = 3
@export var max_energy: int = 3

func _ready() -> void:
	update_energy_display()
	health_bar.setup(max_health, true)  # 100 max HP, show numbers

func take_damage(amount: int) -> void:
	# First reduce block
	if block > 0:
		var blocked = min(block, amount)
		amount -= blocked
		block -= blocked
		health_bar.set_block(block)
		print("Player blocked ", blocked, " damage.")
	
	# Then reduce health
	if amount > 0:
		health -= amount
		health_bar.set_health(health)
		print("Player took ", amount, " damage. Health: ", health)
	
	damage_taken.emit(amount)    
	
	if health <= 0:
		died.emit()

func gain_block(amount: int) -> void:
	block += amount
	health_bar.set_block(block)
	block_gained.emit(amount)

func update_energy_display() -> void:
	energy_changed.emit(current_energy, max_energy)

func start_turn() -> void:
	current_energy = max_energy
	block = 0
	health_bar.set_block(block)
	update_energy_display()

func spend_energy(amount: int) -> void:
	current_energy = max(0, current_energy - amount)
	update_energy_display()

func can_spend_energy(amount: int) -> bool:
	return current_energy >= amount
