class_name LevelButton
extends Control

## Reusable level button component for the level select menu.

# UI Elements
var _button: Button
var _level_label: Label
var _lock_icon: TextureRect
var _star1: TextureRect
var _star2: TextureRect
var _star3: TextureRect

# Textures
@export var yellow_star_texture: Texture2D
@export var dark_star_texture: Texture2D
@export var lock_texture: Texture2D

# Level data
var _level_number: int = 1
var _is_unlocked: bool = false

signal level_selected(level: int)


func _ready() -> void:
	_button = $Button
	_level_label = $Button/LevelLabel
	_lock_icon = $Button/LockIcon
	_star1 = $Stars/Star1
	_star2 = $Stars/Star2
	_star3 = $Stars/Star3
	
	_button.pressed.connect(_on_button_pressed)


func set_level_data(level_number: int, is_unlocked: bool, stars_earned: int) -> void:
	_level_number = level_number
	_is_unlocked = is_unlocked
	
	# Update level number display
	_level_label.text = str(level_number)
	_level_label.visible = is_unlocked
	
	# Update lock icon
	_lock_icon.visible = not is_unlocked
	
	# Update button appearance
	_button.disabled = not is_unlocked
	_button.modulate = Color.WHITE if is_unlocked else Color(0.5, 0.5, 0.5, 1.0)
	
	# Update stars
	_update_stars(stars_earned if is_unlocked else 0)


func _update_stars(stars_earned: int) -> void:
	# Star 1
	if _star1 != null:
		_star1.texture = yellow_star_texture if stars_earned >= 1 else dark_star_texture
	
	# Star 2
	if _star2 != null:
		_star2.texture = yellow_star_texture if stars_earned >= 2 else dark_star_texture
	
	# Star 3
	if _star3 != null:
		_star3.texture = yellow_star_texture if stars_earned >= 3 else dark_star_texture


func _on_button_pressed() -> void:
	if _is_unlocked:
		level_selected.emit(_level_number)
