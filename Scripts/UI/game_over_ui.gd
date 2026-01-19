class_name GameOverUI
extends Control

## Game Over screen with restart and revive options.

var _restart_button: Button
var _revive_button: Button
var _menu_button: Button
var _level_label: Label


func _ready() -> void:
	_restart_button = $VBoxContainer/RestartButton
	_revive_button = $VBoxContainer/ReviveButton
	_menu_button = $VBoxContainer/MenuButton
	_level_label = $VBoxContainer/LevelLabel
	
	_restart_button.pressed.connect(_on_restart_pressed)
	_revive_button.pressed.connect(_on_revive_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)
	
	_update_level_label()


func _update_level_label() -> void:
	if GameManager:
		_level_label.text = "Level %d" % GameManager.current_level


func _on_restart_pressed() -> void:
	# Show interstitial ad before restart
	# TODO: AdMob integration
	
	hide()
	get_tree().reload_current_scene()
	GameManager.restart_level()


func _on_revive_pressed() -> void:
	# TODO: Show rewarded ad for revive
	# After watching ad, revive the player
	
	hide()
	# For now, just restart
	_on_restart_pressed()


func _on_menu_pressed() -> void:
	GameManager.go_to_menu()


func show_ui() -> void:
	_update_level_label()
	visible = true
