using Godot;
using System;
using System.Collections.Generic;
using UpBall.Managers;

namespace UpBall.Entities;

/// <summary>
/// Sistema de spawn de obstáculos e estrelas coletáveis.
/// Gera buracos pretos, o buraco amarelo (objetivo) e estrelas.
/// </summary>
public partial class ObstacleSpawner : Node2D
{
    // Packed scenes for obstacles and collectibles
    [Export] public PackedScene BlackHoleScene { get; set; }
    [Export] public PackedScene YellowHoleScene { get; set; }
    [Export] public PackedScene StarScene { get; set; }

    // Spawn settings
    [Export] public float SpawnY { get; set; } = -100f;
    [Export] public float MinX { get; set; } = 100f;
    [Export] public float MaxX { get; set; } = 620f;

    // Timer for spawning
    private Godot.Timer _spawnTimer;
    private Godot.Timer _starTimer;
    private int _obstaclesSpawned = 0;
    private int _starsSpawned = 0;
    private int _targetObstacles = 5;
    private int _targetStars = 5;
    private float _currentSpeed = 150f;
    private bool _goalSpawned = false;
    private bool _isActive = false;

    // Track positions to avoid overlapping
    private List<float> _recentSpawnX = new List<float>();

    public override void _Ready()
    {
        // Create spawn timer for obstacles
        _spawnTimer = new Godot.Timer();
        _spawnTimer.OneShot = false;
        _spawnTimer.Timeout += OnSpawnTimeout;
        AddChild(_spawnTimer);

        // Create spawn timer for stars
        _starTimer = new Godot.Timer();
        _starTimer.OneShot = false;
        _starTimer.Timeout += OnStarSpawnTimeout;
        AddChild(_starTimer);

        // Connect to GameManager signals
        if (GameManager.Instance != null)
        {
            GameManager.Instance.LevelChanged += OnLevelChanged;
            GameManager.Instance.StateChanged += OnGameStateChanged;
        }
    }

    public void StartSpawning(int level)
    {
        _obstaclesSpawned = 0;
        _starsSpawned = 0;
        _goalSpawned = false;
        _isActive = true;
        _recentSpawnX.Clear();

        // Get difficulty settings from GameManager
        _currentSpeed = GameManager.Instance?.ObstacleSpeed ?? (100f + level * 20f);
        _targetObstacles = GameManager.Instance?.ObstaclesPerLevel ?? (3 + level);
        _targetStars = GameManager.Instance?.StarsPerLevel ?? (3 + level);
        float interval = GameManager.Instance?.SpawnInterval ?? Mathf.Max(1.5f - level * 0.1f, 0.5f);

        // Start obstacle spawning
        _spawnTimer.WaitTime = interval;
        _spawnTimer.Start();

        // Start star spawning (slightly offset from obstacles)
        _starTimer.WaitTime = interval * 0.7f; // Stars spawn more frequently
        _starTimer.Start();
    }

    public void StopSpawning()
    {
        _isActive = false;
        _spawnTimer.Stop();
        _starTimer.Stop();
    }

    public void ClearObstacles()
    {
        // Remove all existing obstacles and stars from parent
        var parent = GetParent();
        foreach (Node child in parent.GetChildren())
        {
            if (child is BlackHole or YellowHole or StarCollectible)
            {
                child.QueueFree();
            }
        }
    }

    private void OnSpawnTimeout()
    {
        if (!_isActive) return;

        if (_obstaclesSpawned < _targetObstacles)
        {
            SpawnBlackHole();
            _obstaclesSpawned++;
        }
        else if (!_goalSpawned)
        {
            SpawnYellowHole();
            _goalSpawned = true;
            _spawnTimer.Stop();
            _starTimer.Stop(); // Stop spawning stars when goal appears
        }
    }

    private void OnStarSpawnTimeout()
    {
        if (!_isActive || _goalSpawned) return;

        if (_starsSpawned < _targetStars)
        {
            SpawnStar();
            _starsSpawned++;
        }
    }

    private void SpawnBlackHole()
    {
        if (BlackHoleScene == null)
        {
            GD.PrintErr("BlackHoleScene not assigned!");
            return;
        }

        var hole = BlackHoleScene.Instantiate<BlackHole>();
        float x = GetRandomXAvoidingRecent();
        hole.Position = new Vector2(x, SpawnY);
        hole.SetSpeed(_currentSpeed);
        GetParent().AddChild(hole);

        TrackSpawnX(x);
    }

    private void SpawnYellowHole()
    {
        if (YellowHoleScene == null)
        {
            GD.PrintErr("YellowHoleScene not assigned!");
            return;
        }

        var goal = YellowHoleScene.Instantiate<YellowHole>();
        goal.Position = new Vector2(GetRandomX(), SpawnY);
        goal.SetSpeed(_currentSpeed);
        GetParent().AddChild(goal);
    }

    private void SpawnStar()
    {
        if (StarScene == null)
        {
            GD.PrintErr("StarScene not assigned!");
            return;
        }

        var star = StarScene.Instantiate<StarCollectible>();
        float x = GetRandomXAvoidingRecent();
        star.Position = new Vector2(x, SpawnY);
        star.SetSpeed(_currentSpeed * 0.9f); // Stars move slightly slower
        GetParent().AddChild(star);

        TrackSpawnX(x);
    }

    private float GetRandomX()
    {
        return (float)GD.RandRange(MinX, MaxX);
    }

    private float GetRandomXAvoidingRecent()
    {
        float x;
        int attempts = 0;
        const float minDistance = 80f;

        do
        {
            x = GetRandomX();
            attempts++;

            // Check if far enough from recent spawns
            bool tooClose = false;
            foreach (float recentX in _recentSpawnX)
            {
                if (Mathf.Abs(x - recentX) < minDistance)
                {
                    tooClose = true;
                    break;
                }
            }

            if (!tooClose || attempts > 10)
                break;

        } while (attempts <= 10);

        return x;
    }

    private void TrackSpawnX(float x)
    {
        _recentSpawnX.Add(x);
        // Keep only last 3 positions
        if (_recentSpawnX.Count > 3)
        {
            _recentSpawnX.RemoveAt(0);
        }
    }

    private void OnLevelChanged(int level)
    {
        StartSpawning(level);
    }

    private void OnGameStateChanged(int state)
    {
        var gameState = (GameManager.GameState)state;
        
        if (gameState == GameManager.GameState.Playing)
        {
            // If restarting, clear and start fresh
            if (!_isActive)
            {
                ClearObstacles();
                StartSpawning(GameManager.Instance?.CurrentLevel ?? 1);
            }
        }
        else if (gameState == GameManager.GameState.GameOver || gameState == GameManager.GameState.Victory)
        {
            StopSpawning();
        }
    }
}
