extends Node

const COMBAT_LOG_MENU = preload("res://scenes/menus/combat_log_menu.tscn")

var combat_log_menu: Control = null
var combat_log_list: VBoxContainer = null

@onready var combat_log_button = %CombatLogButton

func _ready() -> void:
	setup_overlay()
	combat_log_button.pressed.connect(_toggle_combat_log);

func setup_overlay() -> void:
	combat_log_menu = COMBAT_LOG_MENU.instantiate()
	add_child(combat_log_menu)
	var ui_scale_manager = get_node("/root/Main/UIScaleManager")
	ui_scale_manager.register_ui_root(combat_log_menu)
	combat_log_list = combat_log_menu.get_node("%CombatLogList")
	combat_log_menu.hide()

func _toggle_combat_log():
	combat_log_menu.visible = !combat_log_menu.visible
	
	if combat_log_menu.visible:
		combat_log_list.render()
	else:
		combat_log_list.clear()
