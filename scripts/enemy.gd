extends Node

var health: int = 30
var max_health: int = 30
var intent_damage: int = 6

@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	update_health_display()

func take_damage(amount: int) -> void:
	health -= amount
	update_health_display()
	if health <= 0:
		get_node("/root/Main").combat_won()
		

func take_turn() -> void:
	print("Enemy turn")
	var player = get_node("../Player")
	player.take_damage(intent_damage)

func update_health_display() -> void:
	health_label.text = str(health) + "/" + str(max_health)
