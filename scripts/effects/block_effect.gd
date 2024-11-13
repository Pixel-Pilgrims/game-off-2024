# block_effect.gd
extends AbilityEffect
class_name BlockEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("gain_block"):
		target.gain_block(parameters.get("value"))
