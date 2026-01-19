class_name YellowHole
extends Area2D

## Buraco amarelo - objetivo da fase.
## Colisão com a bola = Vitória.

@export var speed: float = 150.0

# Signal when ball enters
signal ball_entered


func _ready() -> void:
	# Connect body entered signal
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Move down the screen
	position += Vector2(0, speed * delta)
	
	# If it goes off screen without being caught, it's a problem
	# but normally the player should catch it before that
	if position.y > 1400:
		queue_free()
		# Optionally trigger game over if objective missed


func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		var ball_node := body as Ball
		# Ball reached the goal - Victory!
		ball_node.on_entered_hole()
		AudioManager.play_victory()
		ball_entered.emit()
		GameManager.trigger_victory()


func set_speed(new_speed: float) -> void:
	speed = new_speed
