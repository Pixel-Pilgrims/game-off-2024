# corrupt_knowledge_effect.gd
extends AbilityEffect
class_name CorruptKnowledgeEffect

func execute(user: Node, target: Node) -> void:
	if target.has_method("corrupt_card_knowledge"):
		target.corrupt_card_knowledge(parameters.get("value"))
