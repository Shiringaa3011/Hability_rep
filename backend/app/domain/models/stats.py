from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import List
from uuid import UUID


class StatsPeriod(str, Enum):
    DAY = "day"
    WEEK = "week"
    MONTH = "month"


@dataclass
class UserStats:
    id: UUID
    user_id: UUID
    period: StatsPeriod
    total_completions: int
    completion_rate: float
    current_streak: int
    max_streak: int
    total_points_period: int
    updated_at: datetime

    def __post_init__(self):
        if not 0 <= self.completion_rate <= 100:
            raise ValueError("Completion rate must be between 0 and 100")
        if self.current_streak < 0:
            raise ValueError("Current streak cannot be negative")
        if self.max_streak < 0:
            raise ValueError("Max streak cannot be negative")


@dataclass
class GroupMemberStats:
    user_id: UUID
    username: str
    rank: int
    total_completions: int
    completion_rate: float
    total_points: int


@dataclass
class GroupStats:
    group_id: UUID
    period: StatsPeriod
    members: List[GroupMemberStats] = field(default_factory=list)
    total_points_group: int = 0
    average_completion_rate: float = 0.0
    total_completions: int = 0
    active_members_count: int = 0
