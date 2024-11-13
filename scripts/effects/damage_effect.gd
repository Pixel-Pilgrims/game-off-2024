# damage_effect.gd
extends AbilityEffect
class_name DamageEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("take_damage"):
		var min_damage: int = parameters.get("min_damage")
		var max_damage: int = parameters.get("max_damage")
		var rolled_damage = randi() % (max_damage + 1) + min_damage
		print("Rolled ", rolled_damage, " damage.")
		target.take_damage(rolled_damage)
