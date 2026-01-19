class_name Ramp
extends Node2D

## Rampa inclinável controlada pelo jogador via drag horizontal.
## A bola rola baseada na inclinação.

# Rotation limits (in degrees)
@export var max_rotation_degrees: float = 30.0

# Sensitivity of drag input
@export var drag_sensitivity: float = 0.3

# Smoothing for rotation
@export var rotation_smoothing: float = 10.0

# Target rotation based on input
var _target_rotation: float = 0.0

# Touch tracking
var _is_dragging: bool = false
var _drag_start_position: Vector2
var _drag_start_rotation: float


func _ready() -> void:
	# Ensure centered rotation
	rotation = 0


func _process(delta: float) -> void:
	# Smoothly interpolate to target rotation
	rotation = lerpf(rotation, _target_rotation, rotation_smoothing * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			# Start dragging
			_is_dragging = true
			_drag_start_position = touch_event.position
			_drag_start_rotation = _target_rotation
		else:
			# Stop dragging
			_is_dragging = false
	
	elif event is InputEventScreenDrag and _is_dragging:
		var drag_event := event as InputEventScreenDrag
		# Calculate horizontal drag delta
		var drag_delta: float = drag_event.position.x - _drag_start_position.x
		
		# Convert to rotation (drag right = rotate right/clockwise)
		var rotation_change: float = drag_delta * drag_sensitivity * 0.01
		
		# Calculate new target rotation
		_target_rotation = _drag_start_rotation + rotation_change
		
		# Clamp to limits
		var max_radians: float = deg_to_rad(max_rotation_degrees)
		_target_rotation = clampf(_target_rotation, -max_radians, max_radians)
	
	# Mouse support for testing in editor
	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				_is_dragging = true
				_drag_start_position = mouse_button.position
				_drag_start_rotation = _target_rotation
			else:
				_is_dragging = false
	
	elif event is InputEventMouseMotion and _is_dragging:
		var mouse_motion := event as InputEventMouseMotion
		var drag_delta: float = mouse_motion.position.x - _drag_start_position.x
		var rotation_change: float = drag_delta * drag_sensitivity * 0.01
		_target_rotation = _drag_start_rotation + rotation_change
		
		var max_radians: float = deg_to_rad(max_rotation_degrees)
		_target_rotation = clampf(_target_rotation, -max_radians, max_radians)


func reset_rotation() -> void:
	_target_rotation = 0.0
	rotation = 0.0
	_is_dragging = false


# Get current rotation in degrees
func get_rotation_degrees_value() -> float:
	return rad_to_deg(rotation)
