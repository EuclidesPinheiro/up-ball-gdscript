class_name Upballfield
extends Node2D

## Main game scene controller.
## Manages the gameplay loop, connecting all entities and UI.

# Entity references
var _ball: Ball
var _ramp: Ramp
var _spawner: ObstacleSpawner

# UI references
var _hud_layer: CanvasLayer
var _game_over_ui: Control
var _victory_ui: Control

# Initial positions
var _ball_start_position: Vector2


func _ready() -> void:
	# Get entity references
	_ball = $Ball
	_ramp = $Ramp
	_spawner = $ObstacleSpawner
	
	# Get UI references
	_hud_layer = $HUD
	_game_over_ui = $UILayer/GameOverUI
	_victory_ui = $UILayer/VictoryUI
	
	# Store initial positions
	_ball_start_position = _ball.global_position
	
	# Connect signals
	_ball.fell_off_ramp.connect(_on_ball_fell_off)
	
	if GameManager:
		GameManager.game_over.connect(_on_game_over)
		GameManager.victory.connect(_on_victory)
		GameManager.state_changed.connect(_on_game_state_changed)
	
	# Hide UI overlays initially
	_game_over_ui.visible = false
	_victory_ui.visible = false
	
	# Start the game if coming from menu
	if GameManager and GameManager.current_state == GameManager.GameState.MENU:
		GameManager.start_game()
	elif GameManager:
		# Already playing, start spawner
		_spawner.start_spawning(GameManager.current_level)


func _exit_tree() -> void:
	# Disconnect signals
	if GameManager:
		if GameManager.game_over.is_connected(_on_game_over):
			GameManager.game_over.disconnect(_on_game_over)
		if GameManager.victory.is_connected(_on_victory):
			GameManager.victory.disconnect(_on_victory)
		if GameManager.state_changed.is_connected(_on_game_state_changed):
			GameManager.state_changed.disconnect(_on_game_state_changed)


func _on_ball_fell_off() -> void:
	GameManager.trigger_game_over()


func _on_game_over() -> void:
	AudioManager.play_game_over()
	_game_over_ui.visible = true


func _on_victory(_stars_earned: int) -> void:
	AudioManager.play_victory()
	# VictoryUI now handles its own visibility via Victory signal


func _on_game_state_changed(state: int) -> void:
	var game_state = state as GameManager.GameState
	
	if game_state == GameManager.GameState.PLAYING:
		# Reset for new level or restart
		_reset_game()


func _reset_game() -> void:
	# Reset ball
	_ball.reset_ball(_ball_start_position)
	_ball.visible = true
	_ball.freeze = false
	
	# Reset ramp
	_ramp.reset_rotation()
	
	# Hide UI
	_game_over_ui.visible = false
	_victory_ui.visible = false
