using Godot;
using System;

namespace UpBall.Entities;

/// <summary>
/// Bola vermelha - ator principal com física realística.
/// Responde à gravidade baseada na inclinação da rampa.
/// </summary>
public partial class Ball : RigidBody2D
{
	// Physics properties
	[Export] public float Friction { get; set; } = 0.3f;
	[Export] public float Bounce { get; set; } = 0.2f;

	// Fall detection
	[Export] public float FallThresholdY { get; set; } = 1400f;

	// Signals
	[Signal] public delegate void FellOffRampEventHandler();

	private bool _hasFallen = false;

	public override void _Ready()
	{
		// Configure physics material
		var physicsMaterial = new PhysicsMaterial();
		physicsMaterial.Friction = Friction;
		physicsMaterial.Bounce = Bounce;
		PhysicsMaterialOverride = physicsMaterial;

		// Enable contact monitoring for collision detection
		ContactMonitor = true;
		MaxContactsReported = 4;
	}

	public override void _PhysicsProcess(double delta)
	{
		// Check if ball fell off the ramp
		if (!_hasFallen && GlobalPosition.Y > FallThresholdY)
		{
			_hasFallen = true;
			EmitSignal(SignalName.FellOffRamp);
		}

		// Also check if ball went too far left or right
		if (!_hasFallen && (GlobalPosition.X < -100 || GlobalPosition.X > 820))
		{
			_hasFallen = true;
			EmitSignal(SignalName.FellOffRamp);
		}
	}

	public void ResetBall(Vector2 position)
	{
		_hasFallen = false;
		GlobalPosition = position;
		LinearVelocity = Vector2.Zero;
		AngularVelocity = 0;
	}

	// Called when entering a hole
	public void OnEnteredHole()
	{
		// Stop physics and hide
		Freeze = true;
		Visible = false;
	}
}
