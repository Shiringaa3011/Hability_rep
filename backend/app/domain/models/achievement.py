from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from uuid import UUID


class AchievementType(str, Enum):
    STREAK = "streak"
    TOTAL_HABITS = "total_habits"
    LEVEL = "level"
    POINTS = "points"
    PERFECT_WEEK = "perfect_week"


@dataclass
class Achievement:
    id: UUID
    name: str
    description: str
    icon: str
    achievement_type: AchievementType
    condition_value: int
    reward_points: int
    is_active: bool

    def check_condition(self, user_value: int) -> bool:
        return user_value >= self.condition_value


@dataclass
class UserAchievement:
    id: UUID
    user_id: UUID
    achievement_id: UUID
    earned_at: datetime
    notified: bool

    def mark_as_notified(self) -> None:
        self.notified = True
