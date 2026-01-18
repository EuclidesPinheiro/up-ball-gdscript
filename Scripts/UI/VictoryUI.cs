using Godot;
using System;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// Victory screen shown when completing a level.
/// Displays star rating based on collectibles gathered.
/// </summary>
public partial class VictoryUI : Control
{
    private Button _nextLevelButton;
    private Button _menuButton;
    private Label _levelLabel;
    private Label _congratsLabel;
    private HBoxContainer _starsContainer;
    private TextureRect _star1;
    private TextureRect _star2;
    private TextureRect _star3;

    [Export] public Texture2D YellowStarTexture { get; set; }
    [Export] public Texture2D DarkStarTexture { get; set; }

    private int _starsEarned = 0;

    public override void _Ready()
    {
        _nextLevelButton = GetNode<Button>("VBoxContainer/NextLevelButton");
        _menuButton = GetNode<Button>("VBoxContainer/MenuButton");
        _levelLabel = GetNode<Label>("VBoxContainer/LevelLabel");
        _congratsLabel = GetNode<Label>("VBoxContainer/CongratsLabel");
        _starsContainer = GetNode<HBoxContainer>("VBoxContainer/StarsContainer");
        _star1 = GetNode<TextureRect>("VBoxContainer/StarsContainer/Star1");
        _star2 = GetNode<TextureRect>("VBoxContainer/StarsContainer/Star2");
        _star3 = GetNode<TextureRect>("VBoxContainer/StarsContainer/Star3");

        _nextLevelButton.Pressed += OnNextLevelPressed;
        _menuButton.Pressed += OnMenuPressed;

        // Connect to victory signal to get stars earned
        if (GameManager.Instance != null)
        {
            GameManager.Instance.Victory += OnVictory;
        }
    }

    public override void _ExitTree()
    {
        if (GameManager.Instance != null)
        {
            GameManager.Instance.Victory -= OnVictory;
        }
    }

    private void OnVictory(int starsEarned)
    {
        _starsEarned = starsEarned;
        UpdateLabels();
        UpdateStars();
        Visible = true;

        // Animate stars appearing
        AnimateStars();
    }

    private void UpdateLabels()
    {
        if (GameManager.Instance != null)
        {
            _levelLabel.Text = $"Level {GameManager.Instance.CurrentLevel} Complete!";
            
            // Update congrats message based on stars
            if (_starsEarned >= 3)
                _congratsLabel.Text = "PERFECT!";
            else if (_starsEarned >= 2)
                _congratsLabel.Text = "GREAT!";
            else if (_starsEarned >= 1)
                _congratsLabel.Text = "GOOD!";
            else
                _congratsLabel.Text = "VICTORY!";
        }
    }

    private void UpdateStars()
    {
        if (_star1 != null && YellowStarTexture != null && DarkStarTexture != null)
        {
            _star1.Texture = _starsEarned >= 1 ? YellowStarTexture : DarkStarTexture;
            _star2.Texture = _starsEarned >= 2 ? YellowStarTexture : DarkStarTexture;
            _star3.Texture = _starsEarned >= 3 ? YellowStarTexture : DarkStarTexture;
        }
    }

    private void AnimateStars()
    {
        // Reset star scales
        if (_star1 != null)
        {
            _star1.Scale = Vector2.Zero;
            _star2.Scale = Vector2.Zero;
            _star3.Scale = Vector2.Zero;

            // Animate each star popping in
            var tween = CreateTween();
            tween.SetTrans(Tween.TransitionType.Elastic);
            tween.SetEase(Tween.EaseType.Out);

            tween.TweenProperty(_star1, "scale", Vector2.One, 0.4f).SetDelay(0.2f);
            tween.TweenProperty(_star2, "scale", Vector2.One, 0.4f).SetDelay(0.1f);
            tween.TweenProperty(_star3, "scale", Vector2.One, 0.4f).SetDelay(0.1f);
        }
    }

    private void OnNextLevelPressed()
    {
        Visible = false;
        GameManager.Instance?.NextLevel();
    }

    private void OnMenuPressed()
    {
        GameManager.Instance?.GoToLevelSelect();
    }

    public new void Show()
    {
        UpdateLabels();
        UpdateStars();
        Visible = true;
    }
}
