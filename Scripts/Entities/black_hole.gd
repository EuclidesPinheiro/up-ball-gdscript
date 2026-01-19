class_name BlackHole
extends Area2D

## Buraco preto - obstáculo que desce pela tela.
## Colisão com a bola = Game Over.

@export var speed: float = 150.0

# Signal when ball enters
signal ball_entered


func _ready() -> void:
	# Connect body entered signal
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Move down the screen
	position += Vector2(0, speed * delta)
	
	# Remove if off screen
	if position.y > 1400:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var ball_node := body as Ball
		# Ball fell into black hole - Game Over
		ball_node.on_entered_hole()
		AudioManager.play_hole_hit()
		ball_entered.emit()
		GameManager.trigger_game_over()


func set_speed(new_speed: float) -> void:
	speed = new_speed
