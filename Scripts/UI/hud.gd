class_name HUD
extends CanvasLayer

## HUD showing current level and star count during gameplay.

var _level_label: Label
var _star_count_label: Label
var _star_icon: TextureRect


func _ready() -> void:
	_level_label = $LevelLabel
	_star_count_label = get_node_or_null("StarContainer/StarCountLabel")
	_star_icon = get_node_or_null("StarContainer/StarIcon")
	
	# Connect to GameManager signals
	if GameManager:
		GameManager.level_changed.connect(_on_level_changed)
		GameManager.star_collected.connect(_on_star_collected)
		_update_level(GameManager.current_level)
		_update_star_count(0, GameManager.total_stars_in_level)


func _exit_tree() -> void:
	if GameManager:
		if GameManager.level_changed.is_connected(_on_level_changed):
			GameManager.level_changed.disconnect(_on_level_changed)
		if GameManager.star_collected.is_connected(_on_star_collected):
			GameManager.star_collected.disconnect(_on_star_collected)


func _on_level_changed(level: int) -> void:
	_update_level(level)
	_update_star_count(0, GameManager.total_stars_in_level if GameManager else 0)


func _on_star_collected(collected: int, total: int) -> void:
	_update_star_count(collected, total)
	_animate_star_collect()


func _update_level(level: int) -> void:
	_level_label.text = "Level %d" % level


func _update_star_count(collected: int, total: int) -> void:
	if _star_count_label != null:
		_star_count_label.text = "%d/%d" % [collected, total]


func _animate_star_collect() -> void:
	if _star_icon != null:
		# Quick pulse animation when collecting a star
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(_star_icon, "scale", Vector2(1.3, 1.3), 0.15)
		tween.tween_property(_star_icon, "scale", Vector2.ONE, 0.2)
