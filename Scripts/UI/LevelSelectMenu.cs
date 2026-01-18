using Godot;
using System;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// Level selection menu showing all levels with their progress.
/// </summary>
public partial class LevelSelectMenu : Control
{
    private Button _backButton;
    private GridContainer _levelGrid;

    [Export] public PackedScene LevelButtonScene { get; set; }
    [Export] public Texture2D YellowStarTexture { get; set; }
    [Export] public Texture2D DarkStarTexture { get; set; }

    public override void _Ready()
    {
        _backButton = GetNode<Button>("TopBar/BackButton");
        _levelGrid = GetNode<GridContainer>("ScrollContainer/LevelGrid");

        _backButton.Pressed += OnBackPressed;

        PopulateLevels();
    }

    private void PopulateLevels()
    {
        // Clear existing buttons
        foreach (Node child in _levelGrid.GetChildren())
        {
            child.QueueFree();
        }

        // Create button for each level
        for (int i = 1; i <= GameManager.TotalLevels; i++)
        {
            var levelData = GameManager.Instance?.GetLevelData(i);
            if (levelData == null) continue;

            if (LevelButtonScene != null)
            {
                var button = LevelButtonScene.Instantiate<LevelButton>();
                _levelGrid.AddChild(button);

                // Set textures
                button.YellowStarTexture = YellowStarTexture;
                button.DarkStarTexture = DarkStarTexture;

                // Set level data
                button.SetLevelData(i, levelData.IsUnlocked, levelData.StarsEarned);

                // Connect signal
                button.LevelSelected += OnLevelSelected;
            }
            else
            {
                // Fallback: create simple button if scene not assigned
                CreateSimpleLevelButton(i, levelData.IsUnlocked, levelData.StarsEarned);
            }
        }
    }

    private void CreateSimpleLevelButton(int level, bool isUnlocked, int stars)
    {
        var container = new VBoxContainer();
        container.CustomMinimumSize = new Vector2(100, 120);

        var button = new Button();
        button.CustomMinimumSize = new Vector2(80, 80);
        button.Text = isUnlocked ? level.ToString() : "🔒";
        button.Disabled = !isUnlocked;

        if (isUnlocked)
        {
            int levelNum = level;
            button.Pressed += () => OnLevelSelected(levelNum);
        }

        container.AddChild(button);

        // Stars container
        var starsContainer = new HBoxContainer();
        starsContainer.Alignment = BoxContainer.AlignmentMode.Center;

        for (int s = 1; s <= 3; s++)
        {
            var starLabel = new Label();
            starLabel.Text = s <= stars ? "⭐" : "☆";
            starsContainer.AddChild(starLabel);
        }

        container.AddChild(starsContainer);
        _levelGrid.AddChild(container);
    }

    private void OnLevelSelected(int level)
    {
        GameManager.Instance?.StartLevel(level);
    }

    private void OnBackPressed()
    {
        GameManager.Instance?.GoToMenu();
    }
}
