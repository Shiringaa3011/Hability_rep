from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID


class HabitFrequency(str, Enum):
    DAILY = "daily"
    WEEKLY = "weekly"


@dataclass
class Habit:
    id: UUID
    user_id: UUID
    name: str
    description: Optional[str]
    frequency: HabitFrequency
    difficulty: int  # 1-5
    target_days: int
    is_active: bool
    created_at: datetime

    def __post_init__(self):
        if not 1 <= self.difficulty <= 5:
            raise ValueError("Difficulty must be between 1 and 5")
        if self.target_days < 1:
            raise ValueError("Target days must be at least 1")

    def calculate_base_points(self) -> int:
        return self.difficulty * 10

    def deactivate(self) -> None:
        self.is_active = False

    def activate(self) -> None:
        self.is_active = True
