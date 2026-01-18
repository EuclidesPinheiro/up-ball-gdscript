using Godot;
using System;

namespace UpBall.Entities;

/// <summary>
/// Rampa inclinável controlada pelo jogador via drag horizontal.
/// A bola rola baseada na inclinação.
/// </summary>
public partial class Ramp : Node2D
{
    // Rotation limits (in degrees)
    [Export] public float MaxRotationDegrees { get; set; } = 30f;
    
    // Sensitivity of drag input
    [Export] public float DragSensitivity { get; set; } = 0.3f;
    
    // Smoothing for rotation
    [Export] public float RotationSmoothing { get; set; } = 10f;

    // Target rotation based on input
    private float _targetRotation = 0f;
    
    // Touch tracking
    private bool _isDragging = false;
    private Vector2 _dragStartPosition;
    private float _dragStartRotation;

    public override void _Ready()
    {
        // Ensure centered rotation
        Rotation = 0;
    }

    public override void _Process(double delta)
    {
        // Smoothly interpolate to target rotation
        Rotation = Mathf.Lerp(Rotation, _targetRotation, (float)(RotationSmoothing * delta));
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventScreenTouch touchEvent)
        {
            if (touchEvent.Pressed)
            {
                // Start dragging
                _isDragging = true;
                _dragStartPosition = touchEvent.Position;
                _dragStartRotation = _targetRotation;
            }
            else
            {
                // Stop dragging
                _isDragging = false;
            }
        }
        else if (@event is InputEventScreenDrag dragEvent && _isDragging)
        {
            // Calculate horizontal drag delta
            float dragDelta = dragEvent.Position.X - _dragStartPosition.X;
            
            // Convert to rotation (drag right = rotate right/clockwise)
            float rotationChange = dragDelta * DragSensitivity * 0.01f;
            
            // Calculate new target rotation
            _targetRotation = _dragStartRotation + rotationChange;
            
            // Clamp to limits
            float maxRadians = Mathf.DegToRad(MaxRotationDegrees);
            _targetRotation = Mathf.Clamp(_targetRotation, -maxRadians, maxRadians);
        }
        // Mouse support for testing in editor
        else if (@event is InputEventMouseButton mouseButton)
        {
            if (mouseButton.ButtonIndex == MouseButton.Left)
            {
                if (mouseButton.Pressed)
                {
                    _isDragging = true;
                    _dragStartPosition = mouseButton.Position;
                    _dragStartRotation = _targetRotation;
                }
                else
                {
                    _isDragging = false;
                }
            }
        }
        else if (@event is InputEventMouseMotion mouseMotion && _isDragging)
        {
            float dragDelta = mouseMotion.Position.X - _dragStartPosition.X;
            float rotationChange = dragDelta * DragSensitivity * 0.01f;
            _targetRotation = _dragStartRotation + rotationChange;
            
            float maxRadians = Mathf.DegToRad(MaxRotationDegrees);
            _targetRotation = Mathf.Clamp(_targetRotation, -maxRadians, maxRadians);
        }
    }

    public void ResetRotation()
    {
        _targetRotation = 0f;
        Rotation = 0f;
        _isDragging = false;
    }

    // Get current rotation in degrees
    public new float GetRotationDegrees()
    {
        return Mathf.RadToDeg(Rotation);
    }
}
