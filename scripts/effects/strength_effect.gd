# strength_effect.gd
extends AbilityEffect
class_name StrengthEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("modify_strength"):
		target.modify_strength(parameters.get("value"))
