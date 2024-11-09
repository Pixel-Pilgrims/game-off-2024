@tool
extends Resource
class_name AbilityData

enum AbilityType {
	ATTACK,
	BLOCK,
	BUFF,
	DEBUFF
}

@export var name: String
@export var type: AbilityType
@export var value: int
@export var weight: int = 1
@export_multiline var description: String
@export var vfx_scene: PackedScene

func get_preview_text() -> String:
	var text = ""
	text += name + "\n"
	match type:
		AbilityType.ATTACK:
			text += "Deals %d damage\n" % value
		AbilityType.BLOCK:
			text += "Gains %d block\n" % value
		AbilityType.BUFF:
			text += "Applies buff: %d\n" % value
		AbilityType.DEBUFF:
			text += "Applies debuff: %d\n" % value
	
	text += "Weight: %d\n" % weight
	if description:
		text += "\n%s" % description
		
	return text

func execute(user: Node, target: Node) -> void:
	match type:
		AbilityType.ATTACK:
			if target.has_method("take_damage"):
				target.take_damage(value)
		AbilityType.BLOCK:
			if user.has_method("gain_block"):
				user.gain_block(value)
		AbilityType.BUFF:
			pass
		AbilityType.DEBUFF:
			pass
	
	if vfx_scene and user.is_inside_tree():
		var vfx = vfx_scene.instantiate()
		user.add_child(vfx)
		if vfx.has_method("play"):
			vfx.play()
