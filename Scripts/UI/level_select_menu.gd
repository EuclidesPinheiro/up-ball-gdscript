class_name LevelSelectMenu
extends Control

## Level selection menu showing all levels with their progress.

var _back_button: Button
var _level_grid: GridContainer

@export var level_button_scene: PackedScene
@export var yellow_star_texture: Texture2D
@export var dark_star_texture: Texture2D


func _ready() -> void:
	_back_button = $TopBar/BackButton
	_level_grid = $ScrollContainer/LevelGrid
	
	_back_button.pressed.connect(_on_back_pressed)
	
	_populate_levels()


func _populate_levels() -> void:
	# Clear existing buttons
	for child in _level_grid.get_children():
		child.queue_free()
	
	# Create button for each level
	for i in range(1, GameManager.TOTAL_LEVELS + 1):
		var level_data: LevelData = GameManager.get_level_data(i)
		if level_data == null:
			continue
		
		if level_button_scene != null:
			var button: LevelButton = level_button_scene.instantiate()
			_level_grid.add_child(button)
			
			# Set textures
			button.yellow_star_texture = yellow_star_texture
			button.dark_star_texture = dark_star_texture
			
			# Set level data
			button.set_level_data(i, level_data.is_unlocked, level_data.stars_earned)
			
			# Connect signal
			button.level_selected.connect(_on_level_selected)
		else:
			# Fallback: create simple button if scene not assigned
			_create_simple_level_button(i, level_data.is_unlocked, level_data.stars_earned)


func _create_simple_level_button(level: int, is_unlocked: bool, stars: int) -> void:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(100, 120)
	
	var button = Button.new()
	button.custom_minimum_size = Vector2(80, 80)
	button.text = str(level) if is_unlocked else "🔒"
	button.disabled = not is_unlocked
	
	if is_unlocked:
		var level_num = level
		button.pressed.connect(func(): _on_level_selected(level_num))
	
	container.add_child(button)
	
	# Stars container
	var stars_container = HBoxContainer.new()
	stars_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	for s in range(1, 4):
		var star_label = Label.new()
		star_label.text = "⭐" if s <= stars else "☆"
		stars_container.add_child(star_label)
	
	container.add_child(stars_container)
	_level_grid.add_child(container)


func _on_level_selected(level: int) -> void:
	GameManager.start_level(level)


func _on_back_pressed() -> void:
	GameManager.go_to_menu()
