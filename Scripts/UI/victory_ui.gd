class_name VictoryUI
extends Control

## Victory screen shown when completing a level.
## Displays star rating based on collectibles gathered.

var _next_level_button: Button
var _menu_button: Button
var _level_label: Label
var _congrats_label: Label
var _stars_container: HBoxContainer
var _star1: TextureRect
var _star2: TextureRect
var _star3: TextureRect

@export var yellow_star_texture: Texture2D
@export var dark_star_texture: Texture2D

var _stars_earned: int = 0


func _ready() -> void:
	_next_level_button = $VBoxContainer/NextLevelButton
	_menu_button = $VBoxContainer/MenuButton
	_level_label = $VBoxContainer/LevelLabel
	_congrats_label = $VBoxContainer/CongratsLabel
	_stars_container = $VBoxContainer/StarsContainer
	_star1 = $VBoxContainer/StarsContainer/Star1
	_star2 = $VBoxContainer/StarsContainer/Star2
	_star3 = $VBoxContainer/StarsContainer/Star3
	
	_next_level_button.pressed.connect(_on_next_level_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)
	
	# Connect to victory signal to get stars earned
	if GameManager:
		GameManager.victory.connect(_on_victory)


func _exit_tree() -> void:
	if GameManager:
		if GameManager.victory.is_connected(_on_victory):
			GameManager.victory.disconnect(_on_victory)


func _on_victory(stars_earned: int) -> void:
	_stars_earned = stars_earned
	_update_labels()
	_update_stars()
	visible = true
	
	# Animate stars appearing
	_animate_stars()


func _update_labels() -> void:
	if GameManager:
		_level_label.text = "Level %d Complete!" % GameManager.current_level
		
		# Update congrats message based on stars
		if _stars_earned >= 3:
			_congrats_label.text = "PERFECT!"
		elif _stars_earned >= 2:
			_congrats_label.text = "GREAT!"
		elif _stars_earned >= 1:
			_congrats_label.text = "GOOD!"
		else:
			_congrats_label.text = "VICTORY!"


func _update_stars() -> void:
	if _star1 != null and yellow_star_texture != null and dark_star_texture != null:
		_star1.texture = yellow_star_texture if _stars_earned >= 1 else dark_star_texture
		_star2.texture = yellow_star_texture if _stars_earned >= 2 else dark_star_texture
		_star3.texture = yellow_star_texture if _stars_earned >= 3 else dark_star_texture


func _animate_stars() -> void:
	# Reset star scales
	if _star1 != null:
		_star1.scale = Vector2.ZERO
		_star2.scale = Vector2.ZERO
		_star3.scale = Vector2.ZERO
		
		# Animate each star popping in
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(_star1, "scale", Vector2.ONE, 0.4).set_delay(0.2)
		tween.tween_property(_star2, "scale", Vector2.ONE, 0.4).set_delay(0.1)
		tween.tween_property(_star3, "scale", Vector2.ONE, 0.4).set_delay(0.1)


func _on_next_level_pressed() -> void:
	visible = false
	GameManager.next_level()


func _on_menu_pressed() -> void:
	GameManager.go_to_level_select()


func show_ui() -> void:
	_update_labels()
	_update_stars()
	visible = true
