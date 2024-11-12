extends Control
class_name HealthBar

@onready var health_bar = $VBoxContainer/HealthBar
@onready var health_label = $VBoxContainer/HealthBar/HealthLabel
@onready var block_bar = $VBoxContainer/BlockBar
@onready var block_label = $VBoxContainer/BlockBar/BlockLabel
@onready var buff_container = $VBoxContainer/BuffContainer
@onready var v_box = $VBoxContainer

const BUFF_ICON_SIZE = Vector2(20, 20)
const VERTICAL_OFFSET = 20  # Distance below the entity

var current_health: float = 100
var max_health: float = 100
var block_amount: float = 0
var show_numbers: bool = true

func _ready():
	setup_styles()
	update_display()
	block_bar.hide()

func setup_styles():
	# Health bar styles
	var health_bg = StyleBoxFlat.new()
	health_bg.bg_color = Color("662b2b")  # Dark red
	health_bg.corner_radius_top_left = 4
	health_bg.corner_radius_top_right = 4
	health_bg.corner_radius_bottom_left = 4
	health_bg.corner_radius_bottom_right = 4
	
	var health_fill = StyleBoxFlat.new()
	health_fill.bg_color = Color("2b662b")  # Dark green
	health_fill.corner_radius_top_left = 4
	health_fill.corner_radius_top_right = 4
	health_fill.corner_radius_bottom_left = 4
	health_fill.corner_radius_bottom_right = 4
	
	health_bar.add_theme_stylebox_override("background", health_bg)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	
	# Block bar styles
	var block_bg = StyleBoxFlat.new()
	block_bg.bg_color = Color("333333")  # Dark gray
	block_bg.corner_radius_top_left = 4
	block_bg.corner_radius_top_right = 4
	block_bg.corner_radius_bottom_left = 4
	block_bg.corner_radius_bottom_right = 4
	
	var block_fill = StyleBoxFlat.new()
	block_fill.bg_color = Color("2b4066")  # Dark blue
	block_fill.corner_radius_top_left = 4
	block_fill.corner_radius_top_right = 4
	block_fill.corner_radius_bottom_left = 4
	block_fill.corner_radius_bottom_right = 4
	
	block_bar.add_theme_stylebox_override("background", block_bg)
	block_bar.add_theme_stylebox_override("fill", block_fill)

func setup(max_hp: float, show_nums: bool = true):
	if not is_node_ready():
		await ready
	max_health = max_hp
	current_health = max_hp
	show_numbers = show_nums
	health_bar.max_value = max_hp
	update_display()
	
func set_health(value: float):
	if not is_node_ready():
		await ready
	current_health = clamp(value, 0, max_health)
	update_display()

func set_block(value: float):
	if not is_node_ready():
		await ready
	block_amount = max(value, 0)
	block_bar.visible = block_amount > 0
	update_display()

func add_buff(buff_icon: Texture2D, duration: int = -1):
	if not is_node_ready():
		await ready
	var buff_sprite = TextureRect.new()
	buff_sprite.texture = buff_icon
	buff_sprite.custom_minimum_size = BUFF_ICON_SIZE
	buff_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	buff_container.add_child(buff_sprite)
	
	if duration > 0:
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func(): remove_buff(buff_sprite))

func remove_buff(buff_sprite: TextureRect):
	if not is_node_ready():
		await ready
	buff_sprite.queue_free()

func update_display():
	if show_numbers:
		health_label.text = "%d/%d" % [current_health, max_health]
		health_label.show()
		block_label.text = "%d" % [block_amount]
	else:
		health_label.hide()
		block_label.hide()
		
	health_bar.value = current_health
