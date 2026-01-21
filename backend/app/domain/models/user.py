from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass
class User:
    id: UUID
    username: str
    email: str
    total_points: int
    current_level: int
    created_at: datetime
    updated_at: datetime

    def add_points(self, points: int) -> None:
        self.total_points += points

    def update_level(self, new_level: int) -> None:
        self.current_level = new_level
