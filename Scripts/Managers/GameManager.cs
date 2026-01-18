using Godot;
using System;
using System.Collections.Generic;
using UpBall.Data;

namespace UpBall.Managers;

/// <summary>
/// Singleton para gerenciar estado global do jogo.
/// </summary>
public partial class GameManager : Node
{
    public static GameManager Instance { get; private set; }

    // Game States
    public enum GameState
    {
        Menu,
        LevelSelect,
        Playing,
        Paused,
        GameOver,
        Victory
    }

    // Current state
    private GameState _currentState = GameState.Menu;
    public GameState CurrentState
    {
        get => _currentState;
        private set
        {
            _currentState = value;
            EmitSignal(SignalName.StateChanged, (int)value);
        }
    }

    // Level and Score
    public int CurrentLevel { get; private set; } = 1;
    public int HighestUnlockedLevel { get; private set; } = 1;
    public const int TotalLevels = 12;

    // Level Data - stores progress for each level
    private Dictionary<int, LevelData> _levelDataDict = new Dictionary<int, LevelData>();

    // Current level star tracking
    public int StarsCollectedInLevel { get; private set; } = 0;
    public int TotalStarsInLevel { get; private set; } = 0;
    public int StarsPerLevel => 3 + CurrentLevel; // Number of star collectibles per level

    // Difficulty settings per level
    public float ObstacleSpeed => 100f + (CurrentLevel * 20f);
    public float SpawnInterval => Mathf.Max(1.5f - (CurrentLevel * 0.1f), 0.5f);
    public int ObstaclesPerLevel => 3 + CurrentLevel;

    // Signals
    [Signal] public delegate void StateChangedEventHandler(int newState);
    [Signal] public delegate void LevelChangedEventHandler(int level);
    [Signal] public delegate void GameOverEventHandler();
    [Signal] public delegate void VictoryEventHandler(int starsEarned);
    [Signal] public delegate void StarCollectedEventHandler(int collected, int total);

    public override void _Ready()
    {
        Instance = this;
        InitializeLevelData();
        LoadProgress();
    }

    private void InitializeLevelData()
    {
        for (int i = 1; i <= TotalLevels; i++)
        {
            _levelDataDict[i] = new LevelData(i, i == 1); // Level 1 starts unlocked
        }
    }

    public LevelData GetLevelData(int level)
    {
        if (_levelDataDict.ContainsKey(level))
            return _levelDataDict[level];
        return null;
    }

    public void StartLevel(int level)
    {
        if (level < 1 || level > TotalLevels) return;
        if (!_levelDataDict[level].IsUnlocked) return;

        CurrentLevel = level;
        StarsCollectedInLevel = 0;
        TotalStarsInLevel = StarsPerLevel;
        CurrentState = GameState.Playing;
        
        GetTree().ChangeSceneToFile("res://Upballfield.tscn");
        EmitSignal(SignalName.LevelChanged, CurrentLevel);
    }

    public void CollectStar()
    {
        StarsCollectedInLevel++;
        EmitSignal(SignalName.StarCollected, StarsCollectedInLevel, TotalStarsInLevel);
    }

    public void RestartLevel()
    {
        StarsCollectedInLevel = 0;
        CurrentState = GameState.Playing;
    }

    public void NextLevel()
    {
        if (CurrentLevel < TotalLevels)
        {
            StartLevel(CurrentLevel + 1);
        }
        else
        {
            GoToLevelSelect();
        }
    }

    public void TriggerGameOver()
    {
        CurrentState = GameState.GameOver;
        EmitSignal(SignalName.GameOver);
    }

    public void TriggerVictory()
    {
        // Calculate star rating based on collection percentage
        float percentage = TotalStarsInLevel > 0 ? (float)StarsCollectedInLevel / TotalStarsInLevel : 0f;
        int starsEarned = LevelData.CalculateStarRating(percentage);

        // Update level data if this is a better result
        var levelData = _levelDataDict[CurrentLevel];
        if (starsEarned > levelData.StarsEarned)
        {
            levelData.StarsEarned = starsEarned;
            levelData.BestPercentage = percentage;
        }

        // Unlock next level
        if (CurrentLevel < TotalLevels && !_levelDataDict[CurrentLevel + 1].IsUnlocked)
        {
            _levelDataDict[CurrentLevel + 1].IsUnlocked = true;
            if (CurrentLevel + 1 > HighestUnlockedLevel)
            {
                HighestUnlockedLevel = CurrentLevel + 1;
            }
        }

        SaveProgress();
        CurrentState = GameState.Victory;
        EmitSignal(SignalName.Victory, starsEarned);
    }

    public void PauseGame()
    {
        if (CurrentState == GameState.Playing)
        {
            CurrentState = GameState.Paused;
            GetTree().Paused = true;
        }
    }

    public void ResumeGame()
    {
        if (CurrentState == GameState.Paused)
        {
            GetTree().Paused = false;
            CurrentState = GameState.Playing;
        }
    }

    public void GoToMenu()
    {
        CurrentState = GameState.Menu;
        GetTree().ChangeSceneToFile("res://Scenes/UI/MainMenu.tscn");
    }

    public void GoToLevelSelect()
    {
        CurrentState = GameState.LevelSelect;
        GetTree().ChangeSceneToFile("res://Scenes/UI/LevelSelectMenu.tscn");
    }

    private void LoadProgress()
    {
        if (!FileAccess.FileExists("user://progress.save")) return;

        using var file = FileAccess.Open("user://progress.save", FileAccess.ModeFlags.Read);
        
        HighestUnlockedLevel = (int)file.Get32();
        
        for (int i = 1; i <= TotalLevels; i++)
        {
            bool unlocked = file.Get8() == 1;
            int stars = (int)file.Get8();
            float percentage = file.GetFloat();

            _levelDataDict[i].IsUnlocked = unlocked;
            _levelDataDict[i].StarsEarned = stars;
            _levelDataDict[i].BestPercentage = percentage;
        }
    }

    private void SaveProgress()
    {
        using var file = FileAccess.Open("user://progress.save", FileAccess.ModeFlags.Write);
        
        file.Store32((uint)HighestUnlockedLevel);
        
        for (int i = 1; i <= TotalLevels; i++)
        {
            var data = _levelDataDict[i];
            file.Store8((byte)(data.IsUnlocked ? 1 : 0));
            file.Store8((byte)data.StarsEarned);
            file.StoreFloat(data.BestPercentage);
        }
    }

    // Legacy compatibility
    public void StartGame()
    {
        StartLevel(1);
    }
}
