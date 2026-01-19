extends Node

## Singleton para gerenciar áudio do jogo.

# Audio players
var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

# Sound effects (load these in _Ready or via export)
@export var sfx_ball_roll: AudioStream
@export var sfx_game_over: AudioStream
@export var sfx_victory: AudioStream
@export var sfx_hole_hit: AudioStream

# Settings
var sfx_volume: float = 1.0
var music_volume: float = 0.7
var sfx_enabled: bool = true
var music_enabled: bool = true


func _ready() -> void:
	_setup_audio_players()


func _setup_audio_players() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)
	
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)


func play_sfx(stream: AudioStream) -> void:
	if not sfx_enabled or stream == null:
		return
	
	_sfx_player.stream = stream
	_sfx_player.volume_db = linear_to_db(sfx_volume)
	_sfx_player.play()


func play_game_over() -> void:
	play_sfx(sfx_game_over)
	trigger_haptic()


func play_victory() -> void:
	play_sfx(sfx_victory)


func play_hole_hit() -> void:
	play_sfx(sfx_hole_hit)
	trigger_haptic()


func trigger_haptic() -> void:
	# Vibração no dispositivo móvel
	Input.vibrate_handheld(100)


func stop_all_sounds() -> void:
	_sfx_player.stop()
	_music_player.stop()
