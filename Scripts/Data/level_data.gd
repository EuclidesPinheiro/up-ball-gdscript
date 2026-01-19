class_name LevelData
extends RefCounted

## Stores progress data for a single level.

var level_number: int = 0
var is_unlocked: bool = false
var stars_earned: int = 0  # 0-3 stars
var best_percentage: float = 0.0  # Best star collection percentage


func _init(p_level_number: int = 0, p_is_unlocked: bool = false) -> void:
	level_number = p_level_number
	is_unlocked = p_is_unlocked
	stars_earned = 0
	best_percentage = 0.0


## Calculate star rating based on collection percentage.
## 1-40% = 1 star, 41-99% = 2 stars, 100% = 3 stars
static func calculate_star_rating(percentage: float) -> int:
	if percentage >= 1.0:
		return 3
	if percentage >= 0.41:
		return 2
	if percentage >= 0.01:
		return 1
	return 0
