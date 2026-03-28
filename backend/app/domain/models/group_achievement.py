from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from uuid import UUID


class GroupAchievementType(str, Enum):
    GROUP_TOTAL_HABITS = "group_total_habits"
    GROUP_ALL_STREAK = "group_all_streak"
    GROUP_PERFECT_WEEK = "group_perfect_week"


@dataclass
class GroupAchievement:
    id: UUID
    name: str
    description: str
    icon: str
    achievement_type: GroupAchievementType
    condition_value: int
    reward_points: int
    is_active: bool

    def check_condition(self, group_value: int) -> bool:
        return group_value >= self.condition_value


@dataclass
class EarnedGroupAchievement:
    id: UUID
    group_id: UUID
    achievement_id: UUID
    earned_at: datetime
    notified: bool

    def mark_as_notified(self) -> None:
        self.notified = True
