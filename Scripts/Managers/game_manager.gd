extends Node

## Singleton para gerenciar estado global do jogo.

# Game States
enum GameState {
	MENU,
	LEVEL_SELECT,
	PLAYING,
	PAUSED,
	GAME_OVER,
	VICTORY
}

# Current state
var _current_state: GameState = GameState.MENU
var current_state: GameState:
	get:
		return _current_state
	set(value):
		_current_state = value
		state_changed.emit(value)

# Level and Score
var current_level: int = 1
var highest_unlocked_level: int = 1
const TOTAL_LEVELS: int = 12

# Level Data - stores progress for each level
var _level_data_dict: Dictionary = {}

# Current level star tracking
var stars_collected_in_level: int = 0
var total_stars_in_level: int = 0
var stars_per_level: int:
	get:
		# Get from level config if available
		var config = LevelConfig.get_config_for_level(current_level)
		return config.star_positions.size()

# Difficulty settings per level (now mainly handled by LevelConfig)
var obstacle_speed: float:
	get:
		var config = LevelConfig.get_config_for_level(current_level)
		return config.obstacle_speed

var spawn_interval: float:
	get:
		var config = LevelConfig.get_config_for_level(current_level)
		return config.spawn_interval

var obstacles_per_level: int:
	get:
		var config = LevelConfig.get_config_for_level(current_level)
		return config.black_hole_positions.size()

# Signals
signal state_changed(new_state: int)
signal level_changed(level: int)
signal game_over()
signal victory(stars_earned: int)
signal star_collected(collected: int, total: int)


func _ready() -> void:
	_initialize_level_data()
	_load_progress()


func _initialize_level_data() -> void:
	for i in range(1, TOTAL_LEVELS + 1):
		_level_data_dict[i] = LevelData.new(i, i == 1)  # Level 1 starts unlocked


func get_level_data(level: int) -> LevelData:
	if _level_data_dict.has(level):
		return _level_data_dict[level]
	return null


func start_level(level: int) -> void:
	if level < 1 or level > TOTAL_LEVELS:
		return
	if not _level_data_dict[level].is_unlocked:
		return
	
	current_level = level
	stars_collected_in_level = 0
	total_stars_in_level = stars_per_level
	current_state = GameState.PLAYING
	
	get_tree().change_scene_to_file("res://Upballfield.tscn")
	level_changed.emit(current_level)


func collect_star() -> void:
	stars_collected_in_level += 1
	star_collected.emit(stars_collected_in_level, total_stars_in_level)


func restart_level() -> void:
	stars_collected_in_level = 0
	current_state = GameState.PLAYING


func next_level() -> void:
	if current_level < TOTAL_LEVELS:
		start_level(current_level + 1)
	else:
		go_to_level_select()


func trigger_game_over() -> void:
	current_state = GameState.GAME_OVER
	game_over.emit()


func trigger_victory() -> void:
	# Calculate star rating based on collection percentage
	var percentage: float = float(stars_collected_in_level) / total_stars_in_level if total_stars_in_level > 0 else 0.0
	var stars_earned: int = LevelData.calculate_star_rating(percentage)
	
	# Update level data if this is a better result
	var level_data: LevelData = _level_data_dict[current_level]
	if stars_earned > level_data.stars_earned:
		level_data.stars_earned = stars_earned
		level_data.best_percentage = percentage
	
	# Unlock next level
	if current_level < TOTAL_LEVELS and not _level_data_dict[current_level + 1].is_unlocked:
		_level_data_dict[current_level + 1].is_unlocked = true
		if current_level + 1 > highest_unlocked_level:
			highest_unlocked_level = current_level + 1
	
	_save_progress()
	current_state = GameState.VICTORY
	victory.emit(stars_earned)


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		get_tree().paused = false
		current_state = GameState.PLAYING


func go_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")


func go_to_level_select() -> void:
	current_state = GameState.LEVEL_SELECT
	get_tree().change_scene_to_file("res://Scenes/UI/LevelSelectMenu.tscn")


func _load_progress() -> void:
	if not FileAccess.file_exists("user://progress.save"):
		return
	
	var file = FileAccess.open("user://progress.save", FileAccess.READ)
	if file == null:
		return
	
	highest_unlocked_level = file.get_32()
	
	for i in range(1, TOTAL_LEVELS + 1):
		var unlocked: bool = file.get_8() == 1
		var stars: int = file.get_8()
		var percentage: float = file.get_float()
		
		_level_data_dict[i].is_unlocked = unlocked
		_level_data_dict[i].stars_earned = stars
		_level_data_dict[i].best_percentage = percentage
	
	file.close()


func _save_progress() -> void:
	var file = FileAccess.open("user://progress.save", FileAccess.WRITE)
	if file == null:
		return
	
	file.store_32(highest_unlocked_level)
	
	for i in range(1, TOTAL_LEVELS + 1):
		var data: LevelData = _level_data_dict[i]
		file.store_8(1 if data.is_unlocked else 0)
		file.store_8(data.stars_earned)
		file.store_float(data.best_percentage)
	
	file.close()


# Legacy compatibility
func start_game() -> void:
	start_level(1)
