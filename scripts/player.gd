extends Node2D

@export var health: int = 40
@export var current_energy = 3
@export var max_energy = 3
@export var max_health: int = 40
@export var block: int = 0

@onready var health_label = $HealthLabel

func _ready() -> void:
	update_health_display()

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
		
	update_health_display()
	
	if health <= 0:
		die()

func gain_block(amount: int) -> void:
	block += amount
	print("Player gained ", amount, " block. Total block: ", block)
	update_health_display()

func update_health_display() -> void:
	var block_text = " [" + str(block) + "]" if block > 0 else ""
	health_label.text = str(health) + "/" + str(max_health) + block_text

func die() -> void:
	print("Game Over!")
	# Handle game over logic
