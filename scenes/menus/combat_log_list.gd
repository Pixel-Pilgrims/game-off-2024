extends VBoxContainer

func render():
	var logs = CombatLogSystem.all()
	
	for index in range(logs.size() - 1, -1, -1):
		var label = Label.new()
		label.text = logs[index]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(label)
		
func clear():
	for log in get_children():
		log.queue_free()
