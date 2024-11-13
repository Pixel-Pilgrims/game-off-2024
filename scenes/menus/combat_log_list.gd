extends VBoxContainer

func render():
	for log in CombatLogSystem.all():
		var label = Label.new()
		label.text = log
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(label)
		
func clear():
	for log in get_children():
		log.queue_free()
