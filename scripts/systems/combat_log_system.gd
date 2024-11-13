extends Node

var logs: Array[String] = []

func add(text: String) -> void:
	logs.append(text)
	
func all() -> Array[String]:
	return logs
	
func clear() -> void:
	logs = []
