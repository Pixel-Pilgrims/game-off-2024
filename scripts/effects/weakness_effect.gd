# effects/weakness_effect.gd
extends AbilityEffect
class_name WeaknessEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("apply_weakness"):
		target.apply_weakness(parameters.get("value"))
