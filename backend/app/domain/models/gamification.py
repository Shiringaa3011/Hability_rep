from dataclasses import dataclass
from typing import Optional
from uuid import UUID


@dataclass
class UserLevel:
    user_id: UUID
    level: int
    total_points: int
    points_to_next_level: int
    progress_percent: float

    def __post_init__(self):
        if self.level < 0:
            raise ValueError("Level cannot be negative")
        if self.total_points < 0:
            raise ValueError("Total points cannot be negative")
        if not 0 <= self.progress_percent <= 100:
            raise ValueError("Progress percent must be between 0 and 100")


@dataclass
class StreakInfo:
    habit_id: UUID
    current_streak: int
    max_streak: int
    last_completion_date: Optional[str]


@dataclass
class HabitStats:
    habit_id: UUID
    habit_name: str
    total_completions: int
    current_streak: int
    max_streak: int
    total_points_earned: int
    completion_rate: float


def calculate_level(total_points: int) -> int:
    if total_points < 0:
        raise ValueError("Total points cannot be negative")
    return int((total_points / 100) ** 0.5)


def points_for_next_level(current_level: int) -> int:
    if current_level < 0:
        raise ValueError("Level cannot be negative")
    return (current_level + 1) ** 2 * 100


def calculate_points_with_streak(base_points: int, streak: int) -> int:
    if base_points < 0:
        raise ValueError("Base points cannot be negative")
    if streak < 0:
        raise ValueError("Streak cannot be negative")

    streak_multiplier = 1 + (streak * 0.1)
    return int(base_points * streak_multiplier)
