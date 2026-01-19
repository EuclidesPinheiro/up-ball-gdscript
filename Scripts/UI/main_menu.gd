class_name MainMenu
extends Control

## Main Menu screen with juicy button animations.

var _play_button: TextureButton
var _high_score_label: Label

# Animation properties
var _idle_tween: Tween
var _press_tween: Tween
var _is_hovering: bool = false
var _is_pressed: bool = false

# Animation constants
const IDLE_SCALE_MIN: float = 1.0
const IDLE_SCALE_MAX: float = 1.05
const IDLE_PULSE_DURATION: float = 0.8
const SQUISH_SCALE: float = 0.9
const SQUISH_DURATION: float = 0.1


func _ready() -> void:
	_play_button = $VBoxContainer/PlayButton
	_high_score_label = $VBoxContainer/HighScoreLabel
	
	# Set pivot to center for proper scaling
	_play_button.pivot_offset = _play_button.size / 2
	
	# Connect signals
	_play_button.pressed.connect(_on_play_pressed)
	_play_button.button_down.connect(_on_button_down)
	_play_button.button_up.connect(_on_button_up)
	_play_button.mouse_entered.connect(_on_mouse_entered)
	_play_button.mouse_exited.connect(_on_mouse_exited)
	
	_update_high_score()
	
	# Start idle animation
	_start_idle_animation()


func _exit_tree() -> void:
	# Clean up tweens
	if _idle_tween:
		_idle_tween.kill()
	if _press_tween:
		_press_tween.kill()


func _start_idle_animation() -> void:
	if _is_hovering or _is_pressed:
		return
	
	# Kill any existing idle tween
	if _idle_tween:
		_idle_tween.kill()
	
	# Create breathing/pulse animation
	_idle_tween = create_tween()
	_idle_tween.set_loops()  # Infinite loop
	_idle_tween.set_trans(Tween.TRANS_SINE)
	_idle_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Scale up
	_idle_tween.tween_property(_play_button, "scale", Vector2(IDLE_SCALE_MAX, IDLE_SCALE_MAX), IDLE_PULSE_DURATION)
	# Scale down
	_idle_tween.tween_property(_play_button, "scale", Vector2(IDLE_SCALE_MIN, IDLE_SCALE_MIN), IDLE_PULSE_DURATION)


func _stop_idle_animation() -> void:
	if _idle_tween:
		_idle_tween.kill()
		_idle_tween = null


func _on_mouse_entered() -> void:
	_is_hovering = true
	_stop_idle_animation()
	
	# Scale up slightly on hover
	if _press_tween:
		_press_tween.kill()
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_BACK)
	_press_tween.set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(_play_button, "scale", Vector2(1.1, 1.1), 0.15)


func _on_mouse_exited() -> void:
	_is_hovering = false
	if not _is_pressed:
		# Return to normal and restart idle
		if _press_tween:
			_press_tween.kill()
		_press_tween = create_tween()
		_press_tween.set_trans(Tween.TRANS_SINE)
		_press_tween.set_ease(Tween.EASE_OUT)
		_press_tween.tween_property(_play_button, "scale", Vector2(IDLE_SCALE_MIN, IDLE_SCALE_MIN), 0.2)
		_press_tween.tween_callback(_start_idle_animation)


func _on_button_down() -> void:
	_is_pressed = true
	_stop_idle_animation()
	
	# Squish effect - quick squeeze
	if _press_tween:
		_press_tween.kill()
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_BACK)
	_press_tween.set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(_play_button, "scale", Vector2(SQUISH_SCALE, SQUISH_SCALE), SQUISH_DURATION)


func _on_button_up() -> void:
	_is_pressed = false
	
	# Bounce back effect
	if _press_tween:
		_press_tween.kill()
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_ELASTIC)
	_press_tween.set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(_play_button, "scale", Vector2(IDLE_SCALE_MIN, IDLE_SCALE_MIN), 0.3)
	
	# Restart idle if not hovering
	if not _is_hovering:
		_press_tween.tween_callback(_start_idle_animation)


func _update_high_score() -> void:
	if GameManager:
		_high_score_label.text = "Best Level: %d" % GameManager.highest_unlocked_level


func _on_play_pressed() -> void:
	# Stop all animations before transitioning
	_stop_idle_animation()
	if _press_tween:
		_press_tween.kill()
	
	# Go to level select menu instead of directly starting game
	GameManager.go_to_level_select()
