using Godot;
using System;
using UpBall.Managers;

namespace UpBall.UI;

/// <summary>
/// Game Over screen with restart and revive options.
/// </summary>
public partial class GameOverUI : Control
{
    private Button _restartButton;
    private Button _reviveButton;
    private Button _menuButton;
    private Label _levelLabel;

    public override void _Ready()
    {
        _restartButton = GetNode<Button>("VBoxContainer/RestartButton");
        _reviveButton = GetNode<Button>("VBoxContainer/ReviveButton");
        _menuButton = GetNode<Button>("VBoxContainer/MenuButton");
        _levelLabel = GetNode<Label>("VBoxContainer/LevelLabel");

        _restartButton.Pressed += OnRestartPressed;
        _reviveButton.Pressed += OnRevivePressed;
        _menuButton.Pressed += OnMenuPressed;

        UpdateLevelLabel();
    }

    private void UpdateLevelLabel()
    {
        if (GameManager.Instance != null)
        {
            _levelLabel.Text = $"Level {GameManager.Instance.CurrentLevel}";
        }
    }

    private void OnRestartPressed()
    {
        // Show interstitial ad before restart
        // TODO: AdMob integration
        
        Hide();
        GetTree().ReloadCurrentScene();
        GameManager.Instance?.RestartLevel();
    }

    private void OnRevivePressed()
    {
        // TODO: Show rewarded ad for revive
        // After watching ad, revive the player
        
        Hide();
        // For now, just restart
        OnRestartPressed();
    }

    private void OnMenuPressed()
    {
        GameManager.Instance?.GoToMenu();
    }

    public new void Show()
    {
        UpdateLevelLabel();
        Visible = true;
    }
}
