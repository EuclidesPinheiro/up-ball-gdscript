class_name Ball
extends RigidBody2D

## Bola vermelha - ator principal com física realística.
## Responde à gravidade baseada na inclinação da rampa.

# Physics properties
@export var friction: float = 0.3
@export var bounce: float = 0.2

# Fall detection
@export var fall_threshold_y: float = 1400.0

# Signals
signal fell_off_ramp

var _has_fallen: bool = false


func _ready() -> void:
	# Configure physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = friction
	physics_material.bounce = bounce
	physics_material_override = physics_material
	
	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 4


func _physics_process(_delta: float) -> void:
	# Check if ball fell off the ramp
	if not _has_fallen and global_position.y > fall_threshold_y:
		_has_fallen = true
		fell_off_ramp.emit()
	
	# Also check if ball went too far left or right
	if not _has_fallen and (global_position.x < -100 or global_position.x > 820):
		_has_fallen = true
		fell_off_ramp.emit()


func reset_ball(pos: Vector2) -> void:
	_has_fallen = false
	global_position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0


# Called when entering a hole
func on_entered_hole() -> void:
	# Stop physics and hide
	freeze = true
	visible = false
