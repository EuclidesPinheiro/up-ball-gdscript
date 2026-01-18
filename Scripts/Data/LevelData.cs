using Godot;
using System;

namespace UpBall.Data;

/// <summary>
/// Stores progress data for a single level.
/// </summary>
[Serializable]
public class LevelData
{
    public int LevelNumber { get; set; }
    public bool IsUnlocked { get; set; }
    public int StarsEarned { get; set; } // 0-3 stars
    public float BestPercentage { get; set; } // Best star collection percentage

    public LevelData(int levelNumber, bool isUnlocked = false)
    {
        LevelNumber = levelNumber;
        IsUnlocked = isUnlocked;
        StarsEarned = 0;
        BestPercentage = 0f;
    }

    /// <summary>
    /// Calculate star rating based on collection percentage.
    /// 1-40% = 1 star, 41-99% = 2 stars, 100% = 3 stars
    /// </summary>
    public static int CalculateStarRating(float percentage)
    {
        if (percentage >= 1.0f) return 3;
        if (percentage >= 0.41f) return 2;
        if (percentage >= 0.01f) return 1;
        return 0;
    }
}
