# ability_data_inspector.gd
@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is AbilityData

func _parse_property(object: Object, type: Variant.Type, name: String, 
					hint_type: PropertyHint, hint_string: String, 
					usage_flags: int, wide: bool) -> bool:
	# Add preview after all properties
	if name == "vfx_scene":  # Last property
		var preview = PreviewControl.new(object)
		add_custom_control(preview)
	return false  # Continue normal property handling

class PreviewControl extends VBoxContainer:
	var ability_data: AbilityData
	var preview_label: Label
	
	func _init(object: AbilityData):
		ability_data = object
		custom_minimum_size.y = 100
		
		var title = Label.new()
		title.text = "Preview"
		title.add_theme_font_size_override("font_size", 16)
		add_child(title)
		
		var panel = PanelContainer.new()
		add_child(panel)
		
		preview_label = Label.new()
		preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(preview_label)
		
		# Connect to property changes
		ability_data.changed.connect(_update_preview)
		_update_preview()
	
	func _update_preview():
		preview_label.text = ability_data.get_preview_text()
