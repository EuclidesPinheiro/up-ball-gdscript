using Godot;
using System;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// Main Menu screen with juicy button animations.
/// </summary>
public partial class MainMenu : Control
{
    private TextureButton _playButton;
    private Label _highScoreLabel;

    // Animation properties
    private Tween _idleTween;
    private Tween _pressTween;
    private bool _isHovering = false;
    private bool _isPressed = false;

    // Animation constants
    private const float IdleScaleMin = 1.0f;
    private const float IdleScaleMax = 1.05f;
    private const float IdlePulseDuration = 0.8f;
    private const float SquishScale = 0.9f;
    private const float SquishDuration = 0.1f;

    public override void _Ready()
    {
        _playButton = GetNode<TextureButton>("VBoxContainer/PlayButton");
        _highScoreLabel = GetNode<Label>("VBoxContainer/HighScoreLabel");

        // Set pivot to center for proper scaling
        _playButton.PivotOffset = _playButton.Size / 2;

        // Connect signals
        _playButton.Pressed += OnPlayPressed;
        _playButton.ButtonDown += OnButtonDown;
        _playButton.ButtonUp += OnButtonUp;
        _playButton.MouseEntered += OnMouseEntered;
        _playButton.MouseExited += OnMouseExited;

        UpdateHighScore();

        // Start idle animation
        StartIdleAnimation();
    }

    public override void _ExitTree()
    {
        // Clean up tweens
        _idleTween?.Kill();
        _pressTween?.Kill();
    }

    private void StartIdleAnimation()
    {
        if (_isHovering || _isPressed) return;

        // Kill any existing idle tween
        _idleTween?.Kill();

        // Create breathing/pulse animation
        _idleTween = CreateTween();
        _idleTween.SetLoops(); // Infinite loop
        _idleTween.SetTrans(Tween.TransitionType.Sine);
        _idleTween.SetEase(Tween.EaseType.InOut);

        // Scale up
        _idleTween.TweenProperty(_playButton, "scale", new Vector2(IdleScaleMax, IdleScaleMax), IdlePulseDuration);
        // Scale down
        _idleTween.TweenProperty(_playButton, "scale", new Vector2(IdleScaleMin, IdleScaleMin), IdlePulseDuration);
    }

    private void StopIdleAnimation()
    {
        _idleTween?.Kill();
        _idleTween = null;
    }

    private void OnMouseEntered()
    {
        _isHovering = true;
        StopIdleAnimation();

        // Scale up slightly on hover
        _pressTween?.Kill();
        _pressTween = CreateTween();
        _pressTween.SetTrans(Tween.TransitionType.Back);
        _pressTween.SetEase(Tween.EaseType.Out);
        _pressTween.TweenProperty(_playButton, "scale", new Vector2(1.1f, 1.1f), 0.15f);
    }

    private void OnMouseExited()
    {
        _isHovering = false;
        if (!_isPressed)
        {
            // Return to normal and restart idle
            _pressTween?.Kill();
            _pressTween = CreateTween();
            _pressTween.SetTrans(Tween.TransitionType.Sine);
            _pressTween.SetEase(Tween.EaseType.Out);
            _pressTween.TweenProperty(_playButton, "scale", new Vector2(IdleScaleMin, IdleScaleMin), 0.2f);
            _pressTween.TweenCallback(Callable.From(StartIdleAnimation));
        }
    }

    private void OnButtonDown()
    {
        _isPressed = true;
        StopIdleAnimation();

        // Squish effect - quick squeeze
        _pressTween?.Kill();
        _pressTween = CreateTween();
        _pressTween.SetTrans(Tween.TransitionType.Back);
        _pressTween.SetEase(Tween.EaseType.Out);
        _pressTween.TweenProperty(_playButton, "scale", new Vector2(SquishScale, SquishScale), SquishDuration);
    }

    private void OnButtonUp()
    {
        _isPressed = false;

        // Bounce back effect
        _pressTween?.Kill();
        _pressTween = CreateTween();
        _pressTween.SetTrans(Tween.TransitionType.Elastic);
        _pressTween.SetEase(Tween.EaseType.Out);
        _pressTween.TweenProperty(_playButton, "scale", new Vector2(IdleScaleMin, IdleScaleMin), 0.3f);

        // Restart idle if not hovering
        if (!_isHovering)
        {
            _pressTween.TweenCallback(Callable.From(StartIdleAnimation));
        }
    }

    private void UpdateHighScore()
    {
        if (GameManager.Instance != null)
        {
            _highScoreLabel.Text = $"Best Level: {GameManager.Instance.HighestUnlockedLevel}";
        }
    }

    private void OnPlayPressed()
    {
        // Stop all animations before transitioning
        StopIdleAnimation();
        _pressTween?.Kill();

        // Go to level select menu instead of directly starting game
        GameManager.Instance?.GoToLevelSelect();
    }
}
