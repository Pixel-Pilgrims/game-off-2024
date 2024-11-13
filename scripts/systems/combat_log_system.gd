extends Node

var logs: Array[String] = []

func add(text: String) -> void:
	print(text)
	logs.append(text)
	
func all() -> Array[String]:
	return logs
	
func clear() -> void:
	logs = []
