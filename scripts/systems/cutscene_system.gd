extends Node

const CUTSCENE_SCENE_PATH = "res://scenes/cutscene.tscn"

func play_cutscene(cutscene: CutsceneData, callback: Callable) -> void:
	if not cutscene:
		push_error("Invalid cutscene resource")
		return
	
	var cutscene_scene = load(CUTSCENE_SCENE_PATH).instantiate() as CutsceneScene
	get_tree().root.add_child(cutscene_scene)
	cutscene_scene.start_cutscene(cutscene, callback)
