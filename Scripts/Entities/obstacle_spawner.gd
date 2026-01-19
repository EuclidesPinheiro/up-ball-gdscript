class_name ObstacleSpawner
extends Node2D

## Sistema de spawn de obstáculos e estrelas coletáveis.
## Spawna em posições fixas definidas pelo LevelConfig.

# Packed scenes for obstacles and collectibles
@export var black_hole_scene: PackedScene
@export var yellow_hole_scene: PackedScene
@export var star_scene: PackedScene

# Spawn settings
@export var spawn_y: float = -100.0
@export var min_x: float = 150.0
@export var max_x: float = 570.0

# Level configuration
var _level_config: LevelConfig
var _spawn_queue: Array = []  # Queue of items to spawn: {type, x_position}
var _spawn_timer: Timer
var _current_speed: float = 120.0
var _is_active: bool = false


func _ready() -> void:
	# Create spawn timer
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timeout)
	add_child(_spawn_timer)
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.level_changed.connect(_on_level_changed)
		GameManager.state_changed.connect(_on_game_state_changed)


func start_spawning(level: int) -> void:
	print("[ObstacleSpawner] start_spawning called for level: ", level)
	_is_active = true
	_spawn_queue.clear()
	
	# Get level configuration
	_level_config = LevelConfig.get_config_for_level(level)
	_current_speed = _level_config.obstacle_speed
	
	print("[ObstacleSpawner] Config loaded - Stars: ", _level_config.star_positions.size(), 
		  " BlackHoles: ", _level_config.black_hole_positions.size(),
		  " Speed: ", _current_speed)
	
	# Build spawn queue based on level config
	_build_spawn_queue()
	
	print("[ObstacleSpawner] Queue built with ", _spawn_queue.size(), " items")
	
	# Update GameManager with total stars for this level
	if GameManager:
		GameManager.total_stars_in_level = _level_config.star_positions.size()
	
	# Start spawning
	_spawn_next()


func stop_spawning() -> void:
	_is_active = false
	_spawn_timer.stop()
	_spawn_queue.clear()


func clear_obstacles() -> void:
	# Remove all existing obstacles and stars from parent
	var parent_node = get_parent()
	for child in parent_node.get_children():
		if child is BlackHole or child is YellowHole or child is StarCollectible:
			child.queue_free()


func _build_spawn_queue() -> void:
	# Build the queue of items to spawn in order
	# First spawned = will be lowest on screen when everything spawns
	# Order: Black holes FIRST (bottom), then stars (middle), then goal LAST (top)
	
	# Add black holes to queue FIRST (so they're at the bottom)
	for x_pos in _level_config.black_hole_positions:
		_spawn_queue.append({"type": "black_hole", "x": x_pos})
	
	# Add stars to queue (so they're in the middle)
	for x_pos in _level_config.star_positions:
		_spawn_queue.append({"type": "star", "x": x_pos})
	
	# Add goal (yellow hole) LAST (so it's at the top)
	_spawn_queue.append({"type": "goal", "x": _level_config.goal_position_x})


func _spawn_next() -> void:
	if not _is_active or _spawn_queue.is_empty():
		print("[ObstacleSpawner] Queue empty or inactive. Active: ", _is_active, " Queue size: ", _spawn_queue.size())
		return
	
	# Get next item from queue
	var item = _spawn_queue.pop_front()
	var item_type: String = item["type"]
	var item_x: float = item["x"]
	
	print("[ObstacleSpawner] Spawning: ", item_type, " at x=", item_x)
	
	match item_type:
		"star":
			_spawn_star_at(item_x)
		"black_hole":
			_spawn_black_hole_at(item_x)
		"goal":
			_spawn_yellow_hole_at(item_x)
			return  # Goal is last, don't continue timer
	
	# Schedule next spawn
	_spawn_timer.wait_time = _level_config.spawn_interval
	_spawn_timer.start()


func _on_spawn_timeout() -> void:
	_spawn_next()


func _spawn_black_hole_at(x_pos: float) -> void:
	if black_hole_scene == null:
		push_error("BlackHoleScene not assigned!")
		return
	
	var hole: BlackHole = black_hole_scene.instantiate()
	hole.position = Vector2(x_pos, spawn_y)
	hole.set_speed(_current_speed)
	get_parent().add_child(hole)


func _spawn_yellow_hole_at(x_pos: float) -> void:
	if yellow_hole_scene == null:
		push_error("YellowHoleScene not assigned!")
		return
	
	var goal: YellowHole = yellow_hole_scene.instantiate()
	goal.position = Vector2(x_pos, spawn_y)
	goal.set_speed(_current_speed)
	get_parent().add_child(goal)


func _spawn_star_at(x_pos: float) -> void:
	if star_scene == null:
		push_error("StarScene not assigned!")
		return
	
	var star: StarCollectible = star_scene.instantiate()
	star.position = Vector2(x_pos, spawn_y)
	star.set_speed(_current_speed)  # Same speed as other obstacles
	get_parent().add_child(star)


func _on_level_changed(level: int) -> void:
	start_spawning(level)


func _on_game_state_changed(state: int) -> void:
	var game_state = state as GameManager.GameState
	
	if game_state == GameManager.GameState.PLAYING:
		# If restarting, clear and start fresh
		if not _is_active:
			clear_obstacles()
			start_spawning(GameManager.current_level if GameManager else 1)
	elif game_state == GameManager.GameState.GAME_OVER or game_state == GameManager.GameState.VICTORY:
		stop_spawning()
