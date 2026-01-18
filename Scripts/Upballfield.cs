using Godot;
using System;
using UpBall.Entities;
using UpBall.Managers;
using UpBall.UI;

namespace UpBall;

/// <summary>
/// Main game scene controller.
/// Manages the gameplay loop, connecting all entities and UI.
/// </summary>
public partial class Upballfield : Node2D
{
    // Entity references
    private Ball _ball;
    private Ramp _ramp;
    private ObstacleSpawner _spawner;

    // UI references
    private CanvasLayer _hudLayer;
    private Control _gameOverUI;
    private Control _victoryUI;

    // Initial positions
    private Vector2 _ballStartPosition;

    public override void _Ready()
    {
        // Get entity references
        _ball = GetNode<Ball>("Ball");
        _ramp = GetNode<Ramp>("Ramp");
        _spawner = GetNode<ObstacleSpawner>("ObstacleSpawner");

        // Get UI references
        _hudLayer = GetNode<CanvasLayer>("HUD");
        _gameOverUI = GetNode<Control>("UILayer/GameOverUI");
        _victoryUI = GetNode<Control>("UILayer/VictoryUI");

        // Store initial positions
        _ballStartPosition = _ball.GlobalPosition;

        // Connect signals
        _ball.FellOffRamp += OnBallFellOff;

        if (GameManager.Instance != null)
        {
            GameManager.Instance.GameOver += OnGameOver;
            GameManager.Instance.Victory += OnVictory;
            GameManager.Instance.StateChanged += OnGameStateChanged;
        }

        // Hide UI overlays initially
        _gameOverUI.Visible = false;
        _victoryUI.Visible = false;

        // Start the game if coming from menu
        if (GameManager.Instance != null && GameManager.Instance.CurrentState == GameManager.GameState.Menu)
        {
            GameManager.Instance.StartGame();
        }
        else if (GameManager.Instance != null)
        {
            // Already playing, start spawner
            _spawner.StartSpawning(GameManager.Instance.CurrentLevel);
        }
    }

    public override void _ExitTree()
    {
        // Disconnect signals
        if (GameManager.Instance != null)
        {
            GameManager.Instance.GameOver -= OnGameOver;
            GameManager.Instance.Victory -= OnVictory;
            GameManager.Instance.StateChanged -= OnGameStateChanged;
        }
    }

    private void OnBallFellOff()
    {
        GameManager.Instance?.TriggerGameOver();
    }

    private void OnGameOver()
    {
        AudioManager.Instance?.PlayGameOver();
        _gameOverUI.Visible = true;
    }

    private void OnVictory(int starsEarned)
    {
        AudioManager.Instance?.PlayVictory();
        // VictoryUI now handles its own visibility via Victory signal
    }

    private void OnGameStateChanged(int state)
    {
        var gameState = (GameManager.GameState)state;

        if (gameState == GameManager.GameState.Playing)
        {
            // Reset for new level or restart
            ResetGame();
        }
    }

    private void ResetGame()
    {
        // Reset ball
        _ball.ResetBall(_ballStartPosition);
        _ball.Visible = true;
        _ball.Freeze = false;

        // Reset ramp
        _ramp.ResetRotation();

        // Hide UI
        _gameOverUI.Visible = false;
        _victoryUI.Visible = false;
    }
}
