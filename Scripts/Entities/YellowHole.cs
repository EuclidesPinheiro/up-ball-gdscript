using Godot;
using System;
using UpBall.Managers;

namespace UpBall.Entities;

/// <summary>
/// Buraco amarelo - objetivo da fase.
/// Colisão com a bola = Vitória.
/// </summary>
public partial class YellowHole : Area2D
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

        // If it goes off screen without being caught, it's a problem
        // but normally the player should catch it before that
        if (Position.Y > 1400)
        {
            QueueFree();
            // Optionally trigger game over if objective missed
        }
    }

    private void OnBodyEntered(Node2D body)
    {
        if (body is Ball ball)
        {
            // Ball reached the goal - Victory!
            ball.OnEnteredHole();
            AudioManager.Instance?.PlayVictory();
            EmitSignal(SignalName.BallEntered);
            GameManager.Instance?.TriggerVictory();
        }
    }

    public void SetSpeed(float speed)
    {
        Speed = speed;
    }
}
