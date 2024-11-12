extends Node

const COMBAT_LOG_MENU = preload("res://scenes/menus/combat_log_menu.tscn")

var combat_log_menu: Control = null
var combat_log: Array = []

@onready var combat_log_button = %CombatLogButton
@onready var combat_log_list = %CombatLogList

func _ready() -> void:
	setup_overlay()
	combat_log_button.pressed.connect(_toggle_combat_log);

func setup_overlay() -> void:
	combat_log_menu = COMBAT_LOG_MENU.instantiate()
	add_child(combat_log_menu)
	var ui_scale_manager = get_node("/root/Main/UIScaleManager")
	ui_scale_manager.register_ui_root(combat_log_menu)
	combat_log_menu.hide()

func _toggle_combat_log():
	combat_log_menu.visible = !combat_log_menu.visible

func add(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	combat_log_list.add_child(label)
	combat_log.append(text);

func clear() -> void:
	combat_log = [];
