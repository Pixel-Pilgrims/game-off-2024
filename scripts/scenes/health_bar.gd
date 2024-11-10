# health_bar.gd
extends Control

signal health_depleted

@onready var health_label = $VBoxContainer/HealthLabel
@onready var health_bar = $VBoxContainer/HealthBar
@onready var block_bar = $VBoxContainer/BlockBar
@onready var buff_container = $VBoxContainer/BuffContainer

const BUFF_ICON_SIZE = Vector2(20, 20)

var current_health: float = 100
var max_health: float = 100
var block_amount: float = 0
var show_numbers: bool = true

func _ready():
	update_display()
	block_bar.hide()

func setup(max_hp: float, show_nums: bool = true):
	max_health = max_hp
	current_health = max_hp
	show_numbers = show_nums
	health_bar.max_value = max_hp
	update_display()
	
func set_health(value: float):
	var prev_health = current_health
	current_health = clamp(value, 0, max_health)
	
	if current_health <= 0 and prev_health > 0:
		health_depleted.emit()
	
	update_display()

func set_block(value: float):
	block_amount = value
	block_bar.visible = block_amount > 0
	block_bar.value = block_amount
	update_display()

func add_buff(buff_icon: Texture2D, duration: int = -1):
	var buff_sprite = TextureRect.new()
	buff_sprite.texture = buff_icon
	buff_sprite.custom_minimum_size = BUFF_ICON_SIZE
	buff_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	buff_container.add_child(buff_sprite)
	
	if duration > 0:
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func(): remove_buff(buff_sprite))

func remove_buff(buff_sprite: TextureRect):
	buff_sprite.queue_free()

func update_display():
	if show_numbers:
		health_label.text = "%d/%d" % [current_health, max_health]
		health_label.show()
	else:
		health_label.hide()
		
	health_bar.value = current_health
