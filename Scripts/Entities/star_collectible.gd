class_name StarCollectible
extends Area2D

## Collectible star that moves down the screen.
## Collected by the ball to increase star count.

@export var speed: float = 150.0
@export var rotation_speed: float = 2.0

# Animation
var _pulse_tween: Tween

signal collected


func _ready() -> void:
	# Connect body entered signal
	body_entered.connect(_on_body_entered)
	
	# Start pulse animation
	_start_pulse_animation()
	
	# Start rotation
	set_process(true)


func _process(delta: float) -> void:
	# Rotate the star for visual effect
	rotation += rotation_speed * delta


func _physics_process(delta: float) -> void:
	# Move down the screen
	position += Vector2(0, speed * delta)
	
	# Remove if off screen
	if position.y > 1400:
		queue_free()


func _start_pulse_animation() -> void:
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	
	_pulse_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.5)
	_pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		# Collect the star
		GameManager.collect_star()
		AudioManager.play_sfx(null)  # TODO: Add star collect sound
		
		# Play collect animation
		_play_collect_animation()


func _play_collect_animation() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_on_collect_finished)


func _on_collect_finished() -> void:
	collected.emit()
	queue_free()


func set_speed(new_speed: float) -> void:
	speed = new_speed
