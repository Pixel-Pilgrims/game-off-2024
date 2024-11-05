extends Node

var health: int = 30
var max_health: int = 30

@onready var health_label: Label = $HealthLabel

func _ready() -> void:
	update_health_display()

func take_damage(amount: int) -> void:
	health -= amount
	update_health_display()
	if health <= 0:
		queue_free()

func take_turn() -> void:
	print("Enemy turn")
	var player = get_node("/root/Combat/Player")
	if player:
		# This will be replaced with actual ability usage
		pass

func update_health_display() -> void:
	health_label.text = str(health) + "/" + str(max_health)

func setup(enemy_data: EnemyData) -> void:
	if not is_node_ready():
		await ready
	health = enemy_data.health
	max_health = enemy_data.health
	update_health_display()
