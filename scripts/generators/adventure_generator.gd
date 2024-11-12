class_name AdventureGenerator
extends Resource

const NUM_TRACKS = 3  # Exactly 3 parallel tracks
const TOTAL_STAGES = 10
const MIN_PATH_LENGTH = 3
const BOSS_STAGE = TOTAL_STAGES - 1
const MIN_CROSSROADS = 3  # Minimum number of track switching opportunities

const NODE_WEIGHTS = {
	"combat": 70,
	"event": 30
}

const BOSSES = [
	preload("res://resources/enemies/bosses/librarian.tres"),
	preload("res://resources/enemies/bosses/memory_colossus.tres"),
	preload("res://resources/enemies/bosses/void_scholar.tres")
]

# Track structure to maintain vertical positioning
class Track:
	var nodes: Array[EncounterNodeData] = []
	var current_node: EncounterNodeData
	var track_index: int  # 0 = top, 1 = middle, 2 = bottom
	
	func _init(start_node: EncounterNodeData, index: int):
		current_node = start_node
		nodes.append(start_node)
		track_index = index

static func generate_adventure() -> AdventureMapData:
	var adventure = AdventureMapData.new()
	
	# Create start node
	var start_node = StartEncounterNodeData.new()
	adventure.rootEncounterNode = start_node
	
	# Initialize three tracks
	var tracks: Array[Track] = []
	for i in range(NUM_TRACKS):
		var first_node = _create_random_encounter()
		start_node.childNodes.append(first_node)
		tracks.append(Track.new(first_node, i))
	
	# Track crossroads created
	var crossroads_created = 0
	
	# Generate middle stages
	var current_stage = 1
	while current_stage < BOSS_STAGE:
		if crossroads_created < MIN_CROSSROADS and (
			current_stage >= MIN_PATH_LENGTH or 
			BOSS_STAGE - current_stage <= MIN_CROSSROADS - crossroads_created
		):
			_create_crossroads_stage(tracks)
			crossroads_created += 1
		else:
			_create_linear_stage(tracks)
		
		current_stage += 1
	
	# Create boss encounter that all tracks lead to
	var boss_node = _create_boss_encounter()
	for track in tracks:
		track.current_node.childNodes.append(boss_node)
	
	# Create finish node after boss
	var finish_node = FinishEncounterNodeData.new()
	boss_node.childNodes.append(finish_node)
	
	adventure.map_background = load("res://assets/backgrounds/adventure_map_background_parchment.png")
	return adventure

static func _create_crossroads_stage(tracks: Array[Track]) -> void:
	# Create one node per track
	var new_nodes: Array[EncounterNodeData] = []
	for i in range(NUM_TRACKS):
		new_nodes.append(_create_random_encounter())
	
	# Connect each track's current node to two possible next nodes
	for track in tracks:
		var available_nodes = new_nodes.duplicate()
		# Always connect to the node at same vertical position
		track.current_node.childNodes.append(new_nodes[track.track_index])
		
		# Connect to one additional adjacent track
		if track.track_index == 0:  # Top track
			track.current_node.childNodes.append(new_nodes[1])  # Connect to middle
		elif track.track_index == 1:  # Middle track
			# Randomly connect to top or bottom
			track.current_node.childNodes.append(new_nodes[0 if randf() < 0.5 else 2])
		else:  # Bottom track
			track.current_node.childNodes.append(new_nodes[1])  # Connect to middle
	
	# Update track current nodes
	for i in range(NUM_TRACKS):
		tracks[i].current_node = new_nodes[i]
		tracks[i].nodes.append(new_nodes[i])

static func _create_linear_stage(tracks: Array[Track]) -> void:
	# Create one node per track, maintaining vertical positions
	for track in tracks:
		var new_node = _create_random_encounter()
		track.current_node.childNodes.append(new_node)
		track.current_node = new_node
		track.nodes.append(new_node)

static func _create_random_encounter() -> EncounterNodeData:
	var roll = randf() * 100
	var encounter: EncounterNodeData
	
	if roll < NODE_WEIGHTS.combat:
		encounter = CombatEncounterNodeData.new()
		_setup_combat_encounter(encounter as CombatEncounterNodeData)
	else:
		encounter = EventEncounterNodeData.new()
	
	var backgrounds = [
		load("res://assets/backgrounds/library_battleground_1.png"),
	]
	encounter.background = backgrounds[0]
	
	return encounter

static func _create_boss_encounter() -> CombatEncounterNodeData:
	var boss_encounter = CombatEncounterNodeData.new()
	var boss_enemy = BOSSES[randi() % BOSSES.size()]
	
	var enemies_array: Array[EnemyData] = []
	enemies_array.append(boss_enemy)
	
	if boss_enemy.resource_path.contains("librarian"):
		var cultist = load("res://resources/enemies/cultist.tres") as EnemyData
		enemies_array.append_array([cultist, cultist])
	
	boss_encounter.enemies = enemies_array
	boss_encounter.background = load("res://assets/backgrounds/library_battleground_1.png")
	
	return boss_encounter

static func _setup_combat_encounter(combat_node: CombatEncounterNodeData) -> void:
	var enemy_data = load("res://resources/enemies/cultist.tres") as EnemyData
	var enemy_count = randi_range(1, 4)
	
	var enemies_array: Array[EnemyData] = []
	for i in range(enemy_count):
		enemies_array.append(enemy_data)
	
	combat_node.enemies = enemies_array
