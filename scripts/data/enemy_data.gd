# enemy_data.gd
extends Resource
class_name EnemyData

@export var enemy_scene: PackedScene
@export var health: int
@export var abilities: Array[AbilityData] = []
