# ability_data.gd
extends Resource
class_name AbilityData

@export var name: String
@export var icon: Texture2D
@export var effects: Array[AbilityEffect]
@export var weight: int = 1
@export var description: String
@export var vfx_scene: PackedScene

func execute(user: Node, target: Node) -> void:
	for i in range(effects.size()):
		effects[i].execute(user, target)
	
	if vfx_scene and user.is_inside_tree():
		var vfx = vfx_scene.instantiate()
		user.add_child(vfx)
		if vfx.has_method("play"):
			vfx.play()
