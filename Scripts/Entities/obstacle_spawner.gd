class_name ObstacleSpawner
extends Node2D

## Sistema de spawn de obstáculos e estrelas coletáveis.
## Gera buracos pretos, o buraco amarelo (objetivo) e estrelas.

# Packed scenes for obstacles and collectibles
@export var black_hole_scene: PackedScene
@export var yellow_hole_scene: PackedScene
@export var star_scene: PackedScene

# Spawn settings
@export var spawn_y: float = -100.0
@export var min_x: float = 100.0
@export var max_x: float = 620.0

# Timer for spawning
var _spawn_timer: Timer
var _star_timer: Timer
var _obstacles_spawned: int = 0
var _stars_spawned: int = 0
var _target_obstacles: int = 5
var _target_stars: int = 5
var _current_speed: float = 150.0
var _goal_spawned: bool = false
var _is_active: bool = false

# Track positions to avoid overlapping
var _recent_spawn_x: Array[float] = []


func _ready() -> void:
	# Create spawn timer for obstacles
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_on_spawn_timeout)
	add_child(_spawn_timer)
	
	# Create spawn timer for stars
	_star_timer = Timer.new()
	_star_timer.one_shot = false
	_star_timer.timeout.connect(_on_star_spawn_timeout)
	add_child(_star_timer)
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.level_changed.connect(_on_level_changed)
		GameManager.state_changed.connect(_on_game_state_changed)


func start_spawning(level: int) -> void:
	_obstacles_spawned = 0
	_stars_spawned = 0
	_goal_spawned = false
	_is_active = true
	_recent_spawn_x.clear()
	
	# Get difficulty settings from GameManager
	_current_speed = GameManager.obstacle_speed if GameManager else (100.0 + level * 20.0)
	_target_obstacles = GameManager.obstacles_per_level if GameManager else (3 + level)
	_target_stars = GameManager.stars_per_level if GameManager else (3 + level)
	var interval: float = GameManager.spawn_interval if GameManager else maxf(1.5 - level * 0.1, 0.5)
	
	# Start obstacle spawning
	_spawn_timer.wait_time = interval
	_spawn_timer.start()
	
	# Start star spawning (slightly offset from obstacles)
	_star_timer.wait_time = interval * 0.7  # Stars spawn more frequently
	_star_timer.start()


func stop_spawning() -> void:
	_is_active = false
	_spawn_timer.stop()
	_star_timer.stop()


func clear_obstacles() -> void:
	# Remove all existing obstacles and stars from parent
	var parent_node = get_parent()
	for child in parent_node.get_children():
		if child is BlackHole or child is YellowHole or child is StarCollectible:
			child.queue_free()


func _on_spawn_timeout() -> void:
	if not _is_active:
		return
	
	if _obstacles_spawned < _target_obstacles:
		_spawn_black_hole()
		_obstacles_spawned += 1
	elif not _goal_spawned:
		_spawn_yellow_hole()
		_goal_spawned = true
		_spawn_timer.stop()
		_star_timer.stop()  # Stop spawning stars when goal appears


func _on_star_spawn_timeout() -> void:
	if not _is_active or _goal_spawned:
		return
	
	if _stars_spawned < _target_stars:
		_spawn_star()
		_stars_spawned += 1


func _spawn_black_hole() -> void:
	if black_hole_scene == null:
		push_error("BlackHoleScene not assigned!")
		return
	
	var hole: BlackHole = black_hole_scene.instantiate()
	var x: float = _get_random_x_avoiding_recent()
	hole.position = Vector2(x, spawn_y)
	hole.set_speed(_current_speed)
	get_parent().add_child(hole)
	
	_track_spawn_x(x)


func _spawn_yellow_hole() -> void:
	if yellow_hole_scene == null:
		push_error("YellowHoleScene not assigned!")
		return
	
	var goal: YellowHole = yellow_hole_scene.instantiate()
	goal.position = Vector2(_get_random_x(), spawn_y)
	goal.set_speed(_current_speed)
	get_parent().add_child(goal)


func _spawn_star() -> void:
	if star_scene == null:
		push_error("StarScene not assigned!")
		return
	
	var star: StarCollectible = star_scene.instantiate()
	var x: float = _get_random_x_avoiding_recent()
	star.position = Vector2(x, spawn_y)
	star.set_speed(_current_speed * 0.9)  # Stars move slightly slower
	get_parent().add_child(star)
	
	_track_spawn_x(x)


func _get_random_x() -> float:
	return randf_range(min_x, max_x)


func _get_random_x_avoiding_recent() -> float:
	var x: float
	var attempts: int = 0
	const MIN_DISTANCE: float = 80.0
	
	while attempts <= 10:
		x = _get_random_x()
		attempts += 1
		
		# Check if far enough from recent spawns
		var too_close: bool = false
		for recent_x in _recent_spawn_x:
			if absf(x - recent_x) < MIN_DISTANCE:
				too_close = true
				break
		
		if not too_close or attempts > 10:
			break
	
	return x


func _track_spawn_x(x: float) -> void:
	_recent_spawn_x.append(x)
	# Keep only last 3 positions
	if _recent_spawn_x.size() > 3:
		_recent_spawn_x.remove_at(0)


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
