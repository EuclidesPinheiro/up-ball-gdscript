using Godot;
using System;
using UpBall.Managers;

namespace UpBall.Entities;

/// <summary>
/// Collectible star that moves down the screen.
/// Collected by the ball to increase star count.
/// </summary>
public partial class StarCollectible : Area2D
{
    [Export] public float Speed { get; set; } = 150f;
    [Export] public float RotationSpeed { get; set; } = 2f;

    // Animation
    private Tween _pulseTween;

    [Signal] public delegate void CollectedEventHandler();

    public override void _Ready()
    {
        // Connect body entered signal
        BodyEntered += OnBodyEntered;

        // Start pulse animation
        StartPulseAnimation();

        // Start rotation
        SetProcess(true);
    }

    public override void _Process(double delta)
    {
        // Rotate the star for visual effect
        Rotation += RotationSpeed * (float)delta;
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

    private void StartPulseAnimation()
    {
        _pulseTween = CreateTween();
        _pulseTween.SetLoops();
        _pulseTween.SetTrans(Tween.TransitionType.Sine);
        _pulseTween.SetEase(Tween.EaseType.InOut);

        _pulseTween.TweenProperty(this, "scale", new Vector2(1.15f, 1.15f), 0.5f);
        _pulseTween.TweenProperty(this, "scale", new Vector2(1.0f, 1.0f), 0.5f);
    }

    private void OnBodyEntered(Node2D body)
    {
        if (body is Ball)
        {
            // Collect the star
            GameManager.Instance?.CollectStar();
            AudioManager.Instance?.PlaySfx(null); // TODO: Add star collect sound

            // Play collect animation
            PlayCollectAnimation();
        }
    }

    private void PlayCollectAnimation()
    {
        _pulseTween?.Kill();

        var tween = CreateTween();
        tween.SetTrans(Tween.TransitionType.Back);
        tween.SetEase(Tween.EaseType.In);
        tween.Parallel().TweenProperty(this, "scale", new Vector2(1.5f, 1.5f), 0.2f);
        tween.Parallel().TweenProperty(this, "modulate:a", 0f, 0.2f);
        tween.TweenCallback(Callable.From(() => {
            EmitSignal(SignalName.Collected);
            QueueFree();
        }));
    }

    public void SetSpeed(float speed)
    {
        Speed = speed;
    }
}
