extends Node

signal combat_started
signal combat_ended
signal turn_started
signal turn_ended

const GAME_OVER_SCENE = preload("res://scenes/game_over.tscn")

var is_player_turn: bool = true
var turn_count: int = 0
var current_enemy_index: int = -1

@onready var hand_manager: HandManager = $"../HandManager"
@onready var enemies_container: Node = $"../EnemiesContainer" 
@onready var energy_label: Label = $"../UI/HUD/EnergyMarginContainer/EnergyTexture/EnergyLabel"
@onready var player = $"../Player"
@onready var end_turn_button = $"../UI/HUD/EndTurnMarginContainer/EndTurnButton"

func _ready() -> void:
	setup_signal_connections()
	await hand_manager.ready
	await player.ready
	start_combat()

func setup_signal_connections() -> void:
	# Player signals
	player.died.connect(_on_player_died)
	player.energy_changed.connect(_on_player_energy_changed)
	
	# UI signals
	end_turn_button.pressed.connect(end_player_turn)
	
	# Connect to existing enemies
	for enemy in enemies_container.get_children():
		connect_enemy_signals(enemy)
	
	# Connect to future enemies
	enemies_container.child_entered_tree.connect(_on_enemy_added)
	enemies_container.child_exiting_tree.connect(_on_enemy_removed)

func connect_enemy_signals(enemy: Node) -> void:
	if not enemy.died.is_connected(_check_combat_state):
		enemy.died.connect(_check_combat_state)
	if not enemy.attack_executed.is_connected(_on_enemy_attack):
		enemy.attack_executed.connect(_on_enemy_attack)
	if not enemy.turn_ended.is_connected(_on_enemy_turn_ended):
		enemy.turn_ended.connect(_on_enemy_turn_ended)

func disconnect_enemy_signals(enemy: Node) -> void:
	if enemy.died.is_connected(_check_combat_state):
		enemy.died.disconnect(_check_combat_state)
	if enemy.attack_executed.is_connected(_on_enemy_attack):
		enemy.attack_executed.disconnect(_on_enemy_attack)
	if enemy.turn_ended.is_connected(_on_enemy_turn_ended):
		enemy.turn_ended.disconnect(_on_enemy_turn_ended)

func start_combat() -> void:
	combat_started.emit()
	start_player_turn()

func start_player_turn() -> void:
	turn_count += 1
	is_player_turn = true
	current_enemy_index = -1
	turn_started.emit()
	player.start_turn()
	hand_manager.draw_cards(5)
	end_turn_button.disabled = false

func end_player_turn() -> void:
	if not is_player_turn:
		return
		
	is_player_turn = false
	end_turn_button.disabled = true
	hand_manager.discard_hand()
	start_next_enemy_turn()

func start_next_enemy_turn() -> void:
	current_enemy_index += 1
	var enemies = enemies_container.get_children()
	
	# Skip any enemies that were removed during previous turns
	while current_enemy_index < enemies.size() and not is_instance_valid(enemies[current_enemy_index]):
		current_enemy_index += 1
	
	if current_enemy_index >= enemies.size():
		# All enemies have taken their turn
		start_player_turn()
		return
	
	# Start the current enemy's turn
	var current_enemy = enemies[current_enemy_index]
	if current_enemy.has_method("take_turn"):
		current_enemy.take_turn()

func _on_enemy_turn_ended() -> void:
	start_next_enemy_turn()

func _on_enemy_attack(damage: int, enemy: Node) -> void:
	player.take_damage(damage)

func _on_player_energy_changed(new_amount: int, _max_amount: int) -> void:
	energy_label.text = str(new_amount)

func _on_enemy_added(enemy: Node) -> void:
	connect_enemy_signals(enemy)

func _on_enemy_removed(enemy: Node) -> void:
	disconnect_enemy_signals(enemy)
	_check_combat_state()

func _check_combat_state() -> void:
	if enemies_container.get_child_count() <= 1:  # <= 1 because the signal fires before the node is fully removed
		combat_ended.emit()

func _on_player_died() -> void:
	# Save meta progression
	GameState.end_run(false)
	
	var game_over = GAME_OVER_SCENE.instantiate()
	get_node("/root/Main").add_child(game_over)
	
	var stats_label = game_over.get_node("CenterContainer/VBoxContainer/StatsLabel")
	stats_label.text = "Rooms cleared: %d" % GameState.current_run
	
	game_over.continue_pressed.connect(_on_game_over_continue)
	game_over.open()
	get_tree().paused = true

func _on_game_over_continue() -> void:
	get_tree().paused = false
	get_node("/root/Main").get_node("GameOver").queue_free()
	get_node("/root/Main").show_main_menu()
