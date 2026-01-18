using Godot;
using System;
using UpBall.Managers;

namespace UpBall.Entities;

/// <summary>
/// Buraco preto - obstáculo que desce pela tela.
/// Colisão com a bola = Game Over.
/// </summary>
public partial class BlackHole : Area2D
{
	[Export] public float Speed { get; set; } = 150f;

	// Signal when ball enters
	[Signal] public delegate void BallEnteredEventHandler();

	public override void _Ready()
	{
		// Connect body entered signal
		BodyEntered += OnBodyEntered;
	}

	public override void _PhysicsProcess(double delta)
	{
		// Move down the screen
		Position += new Vector2(0, Speed * (float)delta);

		// Remove if off screen
		if (Position.Y > 1400)
		{
			QueueFree();
		}
	}

	private void OnBodyEntered(Node2D body)
	{
		if (body is Ball ball)
		{
			// Ball fell into black hole - Game Over
			ball.OnEnteredHole();
			AudioManager.Instance?.PlayHoleHit();
			EmitSignal(SignalName.BallEntered);
			GameManager.Instance?.TriggerGameOver();
		}
	}

	public void SetSpeed(float speed)
	{
		Speed = speed;
	}
}
