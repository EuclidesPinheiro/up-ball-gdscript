class_name StarCollectible
extends Area2D

## Collectible star that moves down the screen.
## Collected by the ball to increase star count.

@export var speed: float = 150.0
@export var rotation_speed: float = 2.0

# Animation - using simple sin wave instead of Tween for performance
var _time: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _is_collected: bool = false

signal collected


func _ready() -> void:
	# Connect body entered signal
	body_entered.connect(_on_body_entered)
	_base_scale = scale


func _physics_process(delta: float) -> void:
	if _is_collected:
		return
	
	# Move down the screen
	position += Vector2(0, speed * delta)
	
	# Rotate the star for visual effect
	rotation += rotation_speed * delta
	
	# Simple pulse animation using sin wave (much more performant than Tween loops)
	_time += delta * 4.0  # Speed of pulse
	var pulse_scale: float = 1.0 + sin(_time) * 0.075  # 7.5% scale variation
	scale = _base_scale * pulse_scale
	
	# Remove if off screen
	if position.y > 1400:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return
	
	if body is Ball:
		_is_collected = true
		# Disable collision immediately to prevent double collection
		set_deferred("monitoring", false)
		
		# Collect the star
		GameManager.collect_star()
		AudioManager.play_sfx(null)  # TODO: Add star collect sound
		
		# Play collect animation
		_play_collect_animation()


func _play_collect_animation() -> void:
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

