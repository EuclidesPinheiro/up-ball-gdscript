using Godot;
using System;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// HUD showing current level and star count during gameplay.
/// </summary>
public partial class HUD : CanvasLayer
{
    private Label _levelLabel;
    private Label _starCountLabel;
    private TextureRect _starIcon;

    public override void _Ready()
    {
        _levelLabel = GetNode<Label>("LevelLabel");
        _starCountLabel = GetNodeOrNull<Label>("StarContainer/StarCountLabel");
        _starIcon = GetNodeOrNull<TextureRect>("StarContainer/StarIcon");

        // Connect to GameManager signals
        if (GameManager.Instance != null)
        {
            GameManager.Instance.LevelChanged += OnLevelChanged;
            GameManager.Instance.StarCollected += OnStarCollected;
            UpdateLevel(GameManager.Instance.CurrentLevel);
            UpdateStarCount(0, GameManager.Instance.TotalStarsInLevel);
        }
    }

    public override void _ExitTree()
    {
        if (GameManager.Instance != null)
        {
            GameManager.Instance.LevelChanged -= OnLevelChanged;
            GameManager.Instance.StarCollected -= OnStarCollected;
        }
    }

    private void OnLevelChanged(int level)
    {
        UpdateLevel(level);
        UpdateStarCount(0, GameManager.Instance?.TotalStarsInLevel ?? 0);
    }

    private void OnStarCollected(int collected, int total)
    {
        UpdateStarCount(collected, total);
        AnimateStarCollect();
    }

    private void UpdateLevel(int level)
    {
        _levelLabel.Text = $"Level {level}";
    }

    private void UpdateStarCount(int collected, int total)
    {
        if (_starCountLabel != null)
        {
            _starCountLabel.Text = $"{collected}/{total}";
        }
    }

    private void AnimateStarCollect()
    {
        if (_starIcon != null)
        {
            // Quick pulse animation when collecting a star
            var tween = CreateTween();
            tween.SetTrans(Tween.TransitionType.Elastic);
            tween.SetEase(Tween.EaseType.Out);
            tween.TweenProperty(_starIcon, "scale", new Vector2(1.3f, 1.3f), 0.15f);
            tween.TweenProperty(_starIcon, "scale", Vector2.One, 0.2f);
        }
    }
}
