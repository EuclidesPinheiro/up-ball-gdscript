using Godot;
using System;
using UpBall.Data;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// Reusable level button component for the level select menu.
/// </summary>
public partial class LevelButton : Control
{
    // UI Elements
    private Button _button;
    private Label _levelLabel;
    private TextureRect _lockIcon;
    private TextureRect _star1;
    private TextureRect _star2;
    private TextureRect _star3;

    // Textures
    [Export] public Texture2D YellowStarTexture { get; set; }
    [Export] public Texture2D DarkStarTexture { get; set; }
    [Export] public Texture2D LockTexture { get; set; }

    // Level data
    private int _levelNumber = 1;
    private bool _isUnlocked = false;

    [Signal] public delegate void LevelSelectedEventHandler(int level);

    public override void _Ready()
    {
        _button = GetNode<Button>("Button");
        _levelLabel = GetNode<Label>("Button/LevelLabel");
        _lockIcon = GetNode<TextureRect>("Button/LockIcon");
        _star1 = GetNode<TextureRect>("Stars/Star1");
        _star2 = GetNode<TextureRect>("Stars/Star2");
        _star3 = GetNode<TextureRect>("Stars/Star3");

        _button.Pressed += OnButtonPressed;
    }

    public void SetLevelData(int levelNumber, bool isUnlocked, int starsEarned)
    {
        _levelNumber = levelNumber;
        _isUnlocked = isUnlocked;

        // Update level number display
        _levelLabel.Text = levelNumber.ToString();
        _levelLabel.Visible = isUnlocked;

        // Update lock icon
        _lockIcon.Visible = !isUnlocked;

        // Update button appearance
        _button.Disabled = !isUnlocked;
        _button.Modulate = isUnlocked ? Colors.White : new Color(0.5f, 0.5f, 0.5f, 1f);

        // Update stars
        UpdateStars(isUnlocked ? starsEarned : 0);
    }

    private void UpdateStars(int starsEarned)
    {
        // Star 1
        if (_star1 != null)
        {
            _star1.Texture = starsEarned >= 1 ? YellowStarTexture : DarkStarTexture;
        }

        // Star 2
        if (_star2 != null)
        {
            _star2.Texture = starsEarned >= 2 ? YellowStarTexture : DarkStarTexture;
        }

        // Star 3
        if (_star3 != null)
        {
            _star3.Texture = starsEarned >= 3 ? YellowStarTexture : DarkStarTexture;
        }
    }

    private void OnButtonPressed()
    {
        if (_isUnlocked)
        {
            EmitSignal(SignalName.LevelSelected, _levelNumber);
        }
    }
}
