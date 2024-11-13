# force_play_effect.gd
extends AbilityEffect
class_name ForcePlayEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("force_play_cards"):
		target.force_play_cards(parameters.get("value"))
