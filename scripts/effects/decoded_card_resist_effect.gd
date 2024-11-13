# decoded_card_resist_effect.gd
extends AbilityEffect
class_name DecodedCardResistEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("set_decoded_card_resistance"):
		target.set_decoded_card_resistance(parameters.get("value"))
