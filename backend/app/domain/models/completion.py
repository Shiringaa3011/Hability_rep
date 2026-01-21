from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass
class HabitCompletion:
    id: UUID
    habit_id: UUID
    user_id: UUID
    completed_at: datetime
    points_earned: int
    current_streak: int

    def __post_init__(self):
        if self.points_earned < 0:
            raise ValueError("Points earned cannot be negative")
        if self.current_streak < 0:
            raise ValueError("Current streak cannot be negative")
